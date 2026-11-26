import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moschee_app/app.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ganze App auf einem Handy-Bildschirm: Einführung, alle Tabs, Scrollen,
/// Einstellungen. Fängt u. a. den früheren Absturz beim Scrollen ab
/// („ScrollController attached to more than one ScrollPosition“).
Future<void> _start(WidgetTester tester, {bool introSeen = true}) async {
  SharedPreferences.setMockInitialValues({'intro_seen': introSeen});
  await SettingsService.instance.init();
  await AccountService.instance.init();
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const App(splashDuration: Duration.zero));
  // Daten laden, Splash ausblenden.
  await _wait(tester, 2000);
}

/// Animationen durchlaufen lassen (pump(Dauer) zeichnet nur ein Bild).
Future<void> _wait(WidgetTester tester, [int ms = 600]) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _scroll(WidgetTester tester) async {
  final list = find.byType(Scrollable).hitTestable();
  // Senkrecht scrollbare Liste des sichtbaren Tabs.
  final vertical = list.evaluate().where(
    (e) => (e.widget as Scrollable).axisDirection == AxisDirection.down,
  );
  expect(vertical, isNotEmpty);
  final target = find.byWidget(vertical.first.widget);
  await tester.drag(target, const Offset(0, -400));
  await _wait(tester, 500);
  await tester.drag(target, const Offset(0, 400));
  await _wait(tester, 500);
}

void main() {
  testWidgets('Alle Tabs und Einstellungen scrollen ohne Fehler', (
    tester,
  ) async {
    await _start(tester);

    // Start: eigene Moschee, Gebetszeiten, Termine.
    expect(find.text('DITIB Schorndorf'), findsWidgets);
    await _scroll(tester);

    // Moscheen: Liste.
    await tester.tap(find.byIcon(Icons.mosque_outlined));
    await _wait(tester, 500);
    await tester.tap(find.byIcon(Icons.view_list_rounded));
    await _wait(tester, 500);
    await _scroll(tester);

    // Community.
    await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
    await _wait(tester, 500);
    expect(find.text('Nachhilfe Mathe & Physik (Klasse 5–10)'), findsOneWidget);
    await _scroll(tester);

    // Einstellungen über das Zahnrad.
    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await _wait(tester, 600);
    expect(find.byType(SettingsScreen), findsOneWidget);
    await _scroll(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Akzentfarbe wechseln ohne Fehler (früher roter Bildschirm)', (
    tester,
  ) async {
    await _start(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await _wait(tester, 600);
    Finder circle(int i) => find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == AppColors.accentChoices[i],
    );
    await tester.tap(circle(4).first);
    await _wait(tester, 400);
    await tester.tap(circle(0).first);
    await _wait(tester, 400);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Verwaltung: Tab erscheint mit Vorschau, Eintrag anlegen', (
    tester,
  ) async {
    await _start(tester);
    expect(find.text('Manage'), findsNothing);
    await SettingsService.instance.setAdminPreview(true);
    await _wait(tester, 400);
    await tester.tap(find.text('Manage'));
    await _wait(tester, 600);
    expect(find.text('Owner'), findsOneWidget);
    await _scroll(tester);
    await tester.tap(find.text('New entry'));
    await _wait(tester, 800);
    await tester.enterText(find.byType(TextFormField).first, 'Testabend');
    await tester.tap(find.byIcon(Icons.check));
    await _wait(tester, 800);
    expect(find.text('Testabend'), findsWidgets);
    expect(tester.takeException(), isNull);
    await SettingsService.instance.setAdminPreview(false);
    await _wait(tester, 400);
    expect(find.text('Manage'), findsNothing);
  });

  testWidgets('Einstellungen: Sprache zeigt echte Sprache statt „System“', (
    tester,
  ) async {
    await _start(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined).hitTestable());
    await _wait(tester, 600);
    // Testumgebung hat Englisch als Systemsprache.
    expect(find.text('English'), findsOneWidget);
    expect(find.text('System'), findsOneWidget); // nur beim Design
  });

  testWidgets('Einführung: wischen und ohne Konto fortfahren', (tester) async {
    await _start(tester, introSeen: false);
    expect(find.text('Your mosque in your pocket'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await _wait(tester, 600);
    expect(find.text('Without account'), findsOneWidget);
    expect(find.text('With account'), findsOneWidget);
    await tester.tap(find.text('Continue without account'));
    await _wait(tester, 1000);
    expect(SettingsService.instance.introSeen, isTrue);
    expect(find.text('DITIB Schorndorf'), findsWidgets);
  });

  testWidgets('Community: Interesse melden verlangt ein Konto', (tester) async {
    await _start(tester);
    await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
    await _wait(tester, 500);
    await tester.tap(find.text("I'm interested").first);
    await _wait(tester, 400);
    expect(find.text('You need an account for this'), findsOneWidget);
  });
}
