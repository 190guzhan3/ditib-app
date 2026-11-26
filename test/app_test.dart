import 'package:flutter_test/flutter_test.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/data/test_data_repositories.dart';
import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/services/geo.dart';
import 'package:moschee_app/core/services/prayer_times.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  test('Standards: System-Design, Testdaten, Diyanet', () {
    final s = SettingsService.instance;
    expect(s.themeMode.name, 'system');
    expect(s.mode, AppMode.testData);
    expect(s.prayerMethod, PrayerMethod.diyanet);
    expect(s.locale, isNull);
  });

  test('Testdaten: alle 97 Orte der Regionenkarte in 12 Regionen', () async {
    final data = await TestMosqueRepository().load();
    expect(data.regions, hasLength(12));
    expect(data.mosques, hasLength(97));
    expect(data.mosques.where((m) => m.region == 4), hasLength(9));
    final ids = data.mosques.map((m) => m.id).toSet();
    expect(ids, hasLength(97), reason: 'IDs eindeutig');
    for (final a in data.announcements) {
      expect(ids, contains(a.mosqueId));
    }
  });

  test('Meine Moschee (Testdaten): Schorndorf, Umkreis ohne eigene', () async {
    final repo = DataRepository.instance;
    await repo.attach(AppMode.testData);
    expect(repo.primaryMosque?.city, 'Schorndorf');
    final nearby = repo.nearbyMosques;
    expect(nearby.map((m) => m.id), isNot(contains('schorndorf')));
    expect(nearby.map((m) => m.city), contains('Urbach'));
    for (final m in nearby) {
      expect(repo.distanceOf(m)!, lessThanOrEqualTo(20));
    }
    // Termine liegen nie in der Vergangenheit.
    final events = repo.upcomingEvents(['schorndorf']);
    expect(events, isNotEmpty);
    final today = DateTime.now();
    for (final e in events) {
      expect(
        e.start!.isBefore(DateTime(today.year, today.month, today.day)),
        isFalse,
      );
    }
  });

  test('Moschee wählen und Hauptmoschee wechseln', () async {
    final repo = DataRepository.instance;
    await repo.attach(AppMode.testData);
    await repo.toggleMine('waiblingen');
    expect(repo.myMosques.map((m) => m.id), ['schorndorf', 'waiblingen']);
    await repo.makePrimary('waiblingen');
    expect(repo.primaryMosque?.id, 'waiblingen');
    await repo.toggleMine('schorndorf');
    expect(repo.myMosques.map((m) => m.id), ['waiblingen']);
  });

  test('Ohne Standort zählt die Hauptmoschee', () async {
    final repo = DataRepository.instance;
    await repo.attach(AppMode.testData);
    final o = repo.origin!;
    expect(o.isDevice, isFalse);
    expect(o.lat, repo.primaryMosque!.lat);
  });

  test('Kategorien: Standard überall, eigene nur bei der Moschee', () async {
    final repo = DataRepository.instance;
    await repo.attach(AppMode.testData);
    final schorndorf = repo.categoriesFor('schorndorf').map((c) => c.id);
    final urbach = repo.categoriesFor('urbach').map((c) => c.id);
    expect(schorndorf, containsAll(EventCategory.builtInIds));
    expect(schorndorf, contains('schorndorf-frauen'));
    expect(urbach, isNot(contains('schorndorf-frauen')));
    // Unbekannte Kategorie fällt auf „Veranstaltung“ zurück.
    expect(repo.category('gibt-es-nicht').id, EventCategory.event);
  });

  test('Siegel: Schorndorf verifiziert, barrierefrei, Frauenbereich', () async {
    final repo = DataRepository.instance;
    await repo.attach(AppMode.testData);
    final badges = repo.badgesOf(repo.mosque('schorndorf')!).map((b) => b.id);
    expect(badges, containsAll(['verified', 'accessible', 'women_area']));
    final b = repo.badgesOf(repo.mosque('schorndorf')!).first;
    expect(b.name('tr'), isNotEmpty);
    expect(b.description('xx'), b.description('de'));
  });

  test(
    'Verwaltung: Eintrag anlegen, Kategorie löschen, Seite ändern',
    () async {
      final repo = DataRepository.instance;
      await repo.attach(AppMode.testData);
      final before = repo.allEntries('schorndorf').length;
      await repo.saveAnnouncement(
        Announcement(
          id: 'neu',
          mosqueId: 'schorndorf',
          categoryId: 'schorndorf-sport',
          title: 'Tischtennis',
          body: '',
          postedAt: DateTime.now(),
          start: DateTime.now().add(const Duration(days: 3)),
        ),
      );
      expect(repo.allEntries('schorndorf'), hasLength(before + 1));
      await repo.deleteCategory('schorndorf-sport');
      final moved = repo
          .allEntries('schorndorf')
          .firstWhere((a) => a.id == 'neu');
      expect(moved.categoryId, EventCategory.event);
      final m = repo.mosque('schorndorf')!;
      await repo.saveMosque(
        m.withPageInfo(
          about: m.about,
          imagePath: null,
          fridayPrayer: null,
          phone: '07181 1234',
          website: null,
        ),
      );
      expect(repo.mosque('schorndorf')!.phone, '07181 1234');
      expect(repo.mosque('schorndorf')!.fridayPrayer, isNull);
      expect(
        repo.mosque('schorndorf')!.verified,
        isTrue,
        reason: 'Siegel bleiben',
      );
    },
  );

  test('Gebetszeiten Schorndorf: sechs Zeiten in richtiger Reihenfolge', () {
    for (final date in [DateTime(2026, 6, 21), DateTime(2026, 12, 21)]) {
      for (final method in PrayerMethod.values) {
        final day = PrayerTimesCalculator.forDay(
          lat: 48.806,
          lng: 9.528,
          date: date,
          method: method,
        );
        final times = day.times.values.toList();
        expect(times, hasLength(6));
        for (var i = 1; i < times.length; i++) {
          expect(
            times[i].isAfter(times[i - 1]),
            isTrue,
            reason: '$date $method',
          );
        }
      }
    }
  });

  test('Qibla von Schorndorf zeigt nach Südosten', () {
    final q = PrayerTimesCalculator.qiblaDirection(48.806, 9.528);
    expect(q, inInclusiveRange(125, 145));
  });

  test('Entfernung Schorndorf–Waiblingen etwa 16 km', () {
    expect(distanceKm(48.806, 9.528, 48.831, 9.317), closeTo(15.7, 1.5));
  });
}
