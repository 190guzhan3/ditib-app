import 'package:flutter/foundation.dart';
import 'package:moschee_app/core/data/community_repository.dart';
import 'package:moschee_app/core/data/mosque_repository.dart';
import 'package:moschee_app/core/data/test_data_repositories.dart';
import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/models/community_post.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/models/mosque_badge.dart';
import 'package:moschee_app/core/models/team_member.dart';
import 'package:moschee_app/core/services/geo.dart';
import 'package:moschee_app/core/services/location_service.dart';
import 'package:moschee_app/core/services/settings_service.dart';

/// Bezugspunkt für Umkreis und Entfernungen: Standort des Handys oder,
/// ohne Standort, die Hauptmoschee.
typedef Origin = ({double lat, double lng, bool isDevice});

/// Einziger Zugang der Screens zu den Fachdaten.
///
/// Lädt beim Wechsel des [AppMode] die passende Quelle (Testdaten oder
/// Cloud) und bietet die Auswertungen, die mehrere Screens brauchen
/// (eigene Moscheen, Umkreis, Entfernungen, Kategorien).
class DataRepository extends ChangeNotifier {
  DataRepository._() {
    // Neuer Standort: Umkreis und Entfernungen neu berechnen.
    LocationService.instance.addListener(notifyListeners);
  }
  static final DataRepository instance = DataRepository._();

  /// Quellen für die Cloud; werden beim Einbau der Cloud gesetzt.
  static MosqueRepository Function()? cloudMosques;
  static CommunityRepository Function()? cloudCommunity;

  final _settings = SettingsService.instance;
  final _location = LocationService.instance;

  late MosqueRepository _mosqueSource;
  late CommunityRepository _communitySource;

  bool _loading = true;
  bool get loading => _loading;

  List<MosqueRegion> _regions = const [];
  List<MosqueBadge> _badges = const [];
  List<Mosque> _mosques = const [];
  Map<String, Mosque> _byId = const {};
  List<EventCategory> _customCategories = const [];
  List<Announcement> _announcements = const [];
  List<CommunityPost> _posts = const [];
  List<String> _defaultMyMosques = const [];

  List<MosqueRegion> get regions => _regions;
  List<Mosque> get mosques => _mosques;
  List<CommunityPost> get posts => _posts;

  Mosque? mosque(String id) => _byId[id];

  MosqueRegion? region(int? number) {
    for (final r in _regions) {
      if (r.number == number) return r;
    }
    return null;
  }

  List<Mosque> mosquesInRegion(int number) =>
      _mosques.where((m) => m.region == number).toList();

  /// Siegel einer Moschee in der Reihenfolge der Definition.
  List<MosqueBadge> badgesOf(Mosque m) =>
      _badges.where((b) => m.badges.contains(b.id)).toList();

  Future<void> attach(AppMode mode) async {
    _mosqueSource = switch (mode) {
      AppMode.cloud => cloudMosques?.call() ?? TestMosqueRepository(),
      AppMode.testData => TestMosqueRepository(),
    };
    _communitySource = switch (mode) {
      AppMode.cloud => cloudCommunity?.call() ?? TestCommunityRepository(),
      AppMode.testData => TestCommunityRepository(),
    };
    _loading = true;
    notifyListeners();
    await reload();
  }

  /// Neu laden (z. B. „nach unten ziehen“).
  Future<void> reload() async {
    await _loadMosques();
    _posts = await _communitySource.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadMosques() async {
    final data = await _mosqueSource.load();
    _regions = data.regions;
    _badges = data.badges;
    _mosques = [...data.mosques]..sort((a, b) => a.name.compareTo(b.name));
    _byId = {for (final m in _mosques) m.id: m};
    _customCategories = data.categories;
    _announcements = data.announcements;
    _defaultMyMosques = data.defaultMyMosques;
  }

  Future<void> _write(Future<void> Function() change) async {
    await change();
    await _loadMosques();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Kategorien

  static final _builtIn = {
    for (final id in EventCategory.builtInIds)
      id: EventCategory(id: id, colorValue: 0, icon: id),
  };

  /// Kategorie nach ID; unbekannte (z. B. gelöschte) als „Veranstaltung“.
  /// Farben der Standard-Kategorien kommen aus dem Theme (`categoryColor`).
  EventCategory category(String id) =>
      _builtIn[id] ??
      _customCategories.where((c) => c.id == id).firstOrNull ??
      _builtIn[EventCategory.event]!;

  /// Standard-Kategorien und die eigenen der Moschee.
  List<EventCategory> categoriesFor(String mosqueId) => [
    ..._builtIn.values,
    ..._customCategories.where((c) => c.mosqueId == mosqueId),
  ];

  // ---------------------------------------------------------------------
  // Eigene Moscheen, Standort und Umkreis

  /// Eigene Moscheen (erste = Hauptmoschee). Solange der Nutzer nichts
  /// gewählt hat, die Vorauswahl der Testdaten.
  List<Mosque> get myMosques => [
    for (final id in _settings.myMosqueIds ?? _defaultMyMosques) ?_byId[id],
  ];

  Mosque? get primaryMosque {
    final mine = myMosques;
    return mine.isEmpty ? null : mine.first;
  }

  bool isMine(String mosqueId) => myMosques.any((m) => m.id == mosqueId);

  Future<void> toggleMine(String mosqueId) {
    final ids = myMosques.map((m) => m.id).toList();
    ids.contains(mosqueId) ? ids.remove(mosqueId) : ids.add(mosqueId);
    return _settings.setMyMosques(ids);
  }

  /// Macht eine eigene Moschee zur Hauptmoschee (Gebetszeiten, Umkreis).
  Future<void> makePrimary(String mosqueId) {
    final ids = myMosques.map((m) => m.id).where((id) => id != mosqueId);
    return _settings.setMyMosques([mosqueId, ...ids]);
  }

  /// Standort des Handys, sonst Hauptmoschee, sonst `null`.
  Origin? get origin {
    final p = _location.position;
    if (p != null) return (lat: p.lat, lng: p.lng, isDevice: true);
    final m = primaryMosque;
    return m == null ? null : (lat: m.lat, lng: m.lng, isDevice: false);
  }

  /// Entfernung vom Bezugspunkt ([origin]); `null` ohne Bezugspunkt.
  double? distanceOf(Mosque m) {
    final o = origin;
    return o == null ? null : distanceKm(o.lat, o.lng, m.lat, m.lng);
  }

  /// Moscheen im Umkreis, ohne die eigenen, nach Nähe.
  List<Mosque> get nearbyMosques {
    if (origin == null) return const [];
    final radius = _settings.radiusKm;
    final list = [
      for (final m in _mosques)
        if (!isMine(m.id) && distanceOf(m)! <= radius) m,
    ];
    list.sort((a, b) => distanceOf(a)!.compareTo(distanceOf(b)!));
    return list;
  }

  // ---------------------------------------------------------------------
  // Ankündigungen und Termine

  /// Kommende Termine (ab heute) der angegebenen Moscheen, nach Datum.
  List<Announcement> upcomingEvents(Iterable<String> mosqueIds) {
    final ids = mosqueIds.toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _announcements
        .where(
          (a) =>
              ids.contains(a.mosqueId) &&
              a.start != null &&
              !a.start!.isBefore(today),
        )
        .toList()
      ..sort((a, b) => a.start!.compareTo(b.start!));
  }

  /// Hinweise ohne Termin, neueste zuerst.
  List<Announcement> notices(Iterable<String> mosqueIds) {
    final ids = mosqueIds.toSet();
    return _announcements
        .where((a) => ids.contains(a.mosqueId) && a.start == null)
        .toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  /// Alle Einträge einer Moschee für die Verwaltung: kommende Termine,
  /// dann Hinweise, dann vergangene Termine.
  List<Announcement> allEntries(String mosqueId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final past =
        _announcements
            .where(
              (a) =>
                  a.mosqueId == mosqueId &&
                  a.start != null &&
                  a.start!.isBefore(today),
            )
            .toList()
          ..sort((a, b) => b.start!.compareTo(a.start!));
    return [
      ...upcomingEvents([mosqueId]),
      ...notices([mosqueId]),
      ...past,
    ];
  }

  // ---------------------------------------------------------------------
  // Verwaltung (Rechte prüft später das Backend)

  Future<void> saveMosque(Mosque m) =>
      _write(() => _mosqueSource.saveMosque(m));

  Future<void> saveAnnouncement(Announcement a) =>
      _write(() => _mosqueSource.saveAnnouncement(a));

  Future<void> deleteAnnouncement(String id) =>
      _write(() => _mosqueSource.deleteAnnouncement(id));

  Future<void> saveCategory(EventCategory c) =>
      _write(() => _mosqueSource.saveCategory(c));

  Future<void> deleteCategory(String id) =>
      _write(() => _mosqueSource.deleteCategory(id));

  Future<List<TeamMember>> team(String mosqueId) =>
      _mosqueSource.loadTeam(mosqueId);

  Future<void> saveTeamMember(String mosqueId, TeamMember m) =>
      _mosqueSource.saveTeamMember(mosqueId, m);

  Future<void> removeTeamMember(String mosqueId, String memberId) =>
      _mosqueSource.removeTeamMember(mosqueId, memberId);

  // ---------------------------------------------------------------------
  // Community

  Future<void> createPost(CommunityPost post) async {
    await _communitySource.create(post);
    _posts = await _communitySource.load();
    notifyListeners();
  }

  Future<void> setInterest(CommunityPost post, bool interested) async {
    await _communitySource.setInterest(post.id, interested);
    _posts = await _communitySource.load();
    notifyListeners();
  }
}
