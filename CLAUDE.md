# Cemaat (Moschee-App) – Regeln für Claude Code

Flutter-App (Android + iOS, Paket `moschee_app`, Bundle-ID
`com.example.moscheeapp`), die Muslime und Moscheen vernetzt. „Cemaat“ ist
ein Arbeitstitel. Entstanden aus der eigenen App-Vorlage: lokal zuerst,
Cloud/Login liegt vorbereitet in `cloud_template/`.

Ausführliches Konzept (Marktrecherche, Recht, Phasen, Personas):
`docs/konzept.md`. Einrichtung: `docs/SETUP.md`.

## Worum es geht

Ehrenamtlich, nicht kommerziell, evtl. später unter einem Verein/Unternehmen
veröffentlicht.

- Jede Moschee hat eine verifizierte Seite, verwaltet von Inhaber + Admins.
- Mitglieder sehen Ankündigungen und Termine (Cenaze-Gebete, Kurse, Feste)
  ihrer Moschee und der Moscheen im Umkreis bzw. einer manuellen Auswahl.
- Gebetszeiten (lokal berechnet mit `adhan`, Moschee-eigene Zeiten haben
  Vorrang) und Qibla-Kompass.
- Später: Hilfebörse (Hilfe suchen/anbieten), zunächst nur Text, Kontakt über
  „Interesse melden“, kein freier Chat.

## Entscheidungen

| Thema | Stand |
|---|---|
| Framework | Flutter (entschieden) |
| Basis | eigene App-Vorlage (`app_template`) |
| Backend | offen: Firebase (EU-Region) oder Supabase. In jedem Fall nur hinter Repository-Interfaces |
| Zielgruppe | Empfehlung: alle Moscheen, Feld „Verband“ als Filter; Pilot mit DITIB-Gemeinden |
| MVP | Moschee-Seiten, Ankündigungen/Termine, Push, Umkreis, Gebetszeiten, Qibla, Karte (OpenStreetMap/flutter_map), Admin-Bereich, Verifizierung |
| Sprachen | Deutsch (Vorlage), Englisch, Türkisch; später evtl. Arabisch |
| Datenschutz | Religionszugehörigkeit = Art. 9 DSGVO. Datensparsam, App ohne Account nutzbar, Account erst zum Posten |

Datenschutz konkret: Moscheen dürfen genau verortet werden (öffentliche
Orte), Nutzer nur ungefähr oder gar nicht. Keine Mitgliedslisten oder
Zahlungen, solange kein Träger mit Datenschutzkonzept dahintersteht.

## Architektur

- Screens lesen Daten nur über `DataRepository` bzw. ein Repository-Interface,
  nie direkt aus Dateien oder Firestore.
- Pro Fachbereich ein eigenes Repository-Interface (Muster: `ItemRepository`
  mit `LocalItemRepository`/`DemoItemRepository`), kein großer Sammel-Service.
- Repositories heute: `MosqueRepository`, `CommunityRepository`,
  `AccountRepository` (je mit Testdaten-Umsetzung). Screens nutzen nur
  `DataRepository` bzw. `AccountService`.
- Datenquellen-Modi: testData, cloud (umgeschaltet im `SettingsService`).
  Testdaten: `assets/testdata/test_data.json`, erzeugt von
  `tool/build_test_data.py` (Zeiten relativ zu heute).
- Eigene Auswahl (Moscheen, Umkreis, Methode) bleibt im `SettingsService`
  auf dem Gerät. Umkreis, Karte und Qibla zählen ab dem Standort des Handys
  (`LocationService`, nur auf Wunsch, nur ungefähr, nie gespeichert), sonst
  ab der Hauptmoschee (`DataRepository.origin`).
- Kategorien sind Daten: sechs Standard-Kategorien (Name aus l10n, Farbe aus
  dem Theme) plus eigene je Moschee (`EventCategory`). Siegel ebenso
  (`MosqueBadge`, Texte je Sprache in den Daten, gepflegt von der
  App-Leitung). Nie wieder ein festes Enum dafür.
- Verwaltung (`lib/sections/admin`): vorerst über den Schalter „Verwaltung
  (Vorschau)“ in den Einstellungen, Rolle Inhaber für die Hauptmoschee.
  Später Rolle aus der Cloud; Schreibrechte prüft das Backend.
- Backend-Code (Firestore, Storage, Auth) nur im Daten-Ordner bzw. in
  `cloud_template/`.
- Bilder über `ImageStore` speichern (Dateiname statt absolutem Pfad).
- Allgemeine Widgets nach `lib/shared/widgets`, Fachliches nach `lib/sections`.
- Tabs (Start, Moscheen, Community) und Unterseiten ohne Überschrift oben;
  Qibla und Einstellungen über `TabTopBar`. Jeder Tab hat seinen eigenen
  `PrimaryScrollController` (`MainShell`), sonst stürzt die Scrollleiste ab.

## Theme

- Farben, Schriften, Icons und Button-Stile nur aus `lib/core/theme`
  (`app_design.dart`, `theme.dart`), keine fest eingetragenen Werte in Screens.
- `secondary`/`tertiary` im ColorScheme sind die Akzentfarbe, nicht das
  Flutter-Standard-Türkis.
- Kopf-Buttons rund: `AppHeaderIconButton`, `AppBackButton`, `AppSaveButton`.

## Texte (l10n)

- Neue Texte zuerst in `lib/core/l10n/app_de.arb` (Vorlage), dann
  `app_en.arb` und `app_tr.arb`, danach `flutter gen-l10n`.
- Keine festen Texte in Widgets.
- Demo-Daten je Sprache in `assets/demo/demo_<sprache>.json`.

## cloud_template

- Firebase-Anbindung (Setup, Repository, Bilder, Auth, Regeln, Functions)
  und Gruppen-Bausteine (Rollen, Einladungen, Geo, Push, Deep Links)
  werden erst bei Bedarf eingebaut. Anleitung: `cloud_template/README.md`.
- Übertragung auf die Moschee-App: Gruppe → Moschee, Owner/Admin →
  Inhaber/Admin (dazu Redakteur), einmaliger Verwalter-Code = Einladung mit
  `maxUses: 1`, Geohash → Umkreis, Push → Cenaze-Benachrichtigungen.
- `cloud_template/` wird von `flutter analyze` nicht geprüft. Nach
  Änderungen dort selbst prüfen: in einer Kopie mit den Paketen aus
  `pubspec_additions.yaml` analysieren, `node --test` in `functions/`,
  Regeltests in `rules_tests/` (Firestore-Emulator).
- Sensible Vorgänge (Einladungen einlösen, Rollen ändern) als Cloud Function,
  nicht im Client.

## Nächste Aufgaben

1. Backend-Entscheidung treffen (Firebase oder Supabase). `cloud_template/`
   baut noch auf dem alten `ItemRepository` der Vorlage auf; beim Einbau
   je Bereich ein Repository nach dem Muster in `lib/core/data/` schreiben.
2. Datenmodell ergänzen: MosqueMember (Rolle), Invite, Verifizierung.
3. App-Name prüfen (Stores, DPMA, Domain), eigene Bundle-ID statt
   `com.example`. DITIB-Logo im Splash nur mit Zustimmung der DITIB
   veröffentlichen.

## Befehle

```sh
flutter pub get
flutter gen-l10n
flutter analyze && flutter test
```
