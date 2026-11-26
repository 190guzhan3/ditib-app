# Cloud-Vorlage (Firebase)

Die App läuft standardmäßig **ohne Cloud**. Dieser Ordner enthält alles, um
sie bei Bedarf an Firebase anzubinden. Er wird nicht mitkompiliert
(`analysis_options.yaml` schließt ihn aus).

## Inhalt

| Datei | Zweck |
|---|---|
| `lib/cloud_setup.dart` | Firebase-Start: Crashlytics, App Check, Offline-Cache, Anbindung an `DataRepository` |
| `lib/firestore_item_repository.dart` | `ItemRepository` für Firestore (`users/{uid}/items`), live per `watch()`, Import lokaler Daten |
| `lib/cloud_image_store.dart` | Bilder in Firebase Storage, lange Cache-Dauer, `CachedNetworkImageProvider` |
| `lib/firebase/auth_service.dart` | Anmeldung (E-Mail, Google, Apple), Konto löschen mit Re-Auth |
| `lib/firebase/auth_errors.dart` | Firebase-Fehlercodes → verständliche Texte |
| `lib/firebase/apple_sign_in_button.dart` | Apple-Button nach Apple-Richtlinien |
| `l10n_auth_additions.json` | Texte für `auth_errors.dart` (DE/EN) → in die ARB-Dateien übernehmen |
| `firestore.rules`, `storage.rules` | Sicherheitsregeln: jeder Nutzer nur seine Daten |
| `firebase.json`, `firestore.indexes.json` | Firebase-Projektkonfiguration inkl. Emulatoren |
| `lib/groups/group_roles.dart` | Rollen owner/admin/member, `GroupPermissions` (was darf der Nutzer) |
| `lib/groups/group_invite.dart` | Einladung mit Ablauf, `maxUses`, Rolle; Links bauen und erkennen |
| `lib/groups/group_access.dart` | Repository-Interface `GroupAccess` (Rechte, Rollen, Einladungen) |
| `lib/groups/firestore_group_access.dart` | `GroupAccess` über Firestore + Functions |
| `lib/geo.dart` | Geohash, Entfernung, Umkreissuche (reines Dart) |
| `lib/notification_service.dart` | Push (FCM): Token je Gerät speichern/entfernen, angetippte Nachricht öffnen |
| `lib/deep_link_service.dart` | Einladungslinks entgegennehmen (App Links / eigenes Schema) |
| `test/cloud_groups_test.dart` | Tests für Rollen, Einladungslinks, Geo → nach `test/` kopieren |
| `functions/` | Kontolöschung, `redeemGroupInvite`, `setGroupRole`, Push-Versand `notifyUsers`; Logik in `group_access.js` (Tests: `node --test`) |
| `rules_tests/` | Tests der Firestore-Regeln gegen den Emulator (`npm install && npm test`) |
| `pubspec_additions.yaml` | Benötigte Pakete |
| `native/` | iOS-Entitlements (Push, Apple-Login, Universal Links) |

## Einbauen (Schritt für Schritt)

1. **Firebase-Projekt** in der Konsole anlegen, dann im Projektordner:
   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure        # erzeugt lib/firebase_options.dart + native Konfig
   ```
2. **Pakete** aus `pubspec_additions.yaml` hinzufügen, `flutter pub get`.
3. **Dateien kopieren**: `cloud_template/lib/*` → `lib/cloud/`
   (inkl. `firebase/`, `groups/`; nicht Benötigtes weglassen), die
   Konfigdateien (`firebase.json`, Regeln, Indizes, `functions/`,
   `rules_tests/`) ins Projektverzeichnis, `test/*` nach `test/`.
   Texte aus `l10n_auth_additions.json` in die ARB-Dateien übernehmen,
   dann `flutter gen-l10n`.
4. **main.dart**: vor `SettingsService.instance.init()` aufrufen:
   ```dart
   await CloudSetup.init();
   ```
5. **Bilder aus dem Netz cachen**: in `lib/core/services/image_store.dart`
   `NetworkImage(path)` durch `CachedNetworkImageProvider(path)` ersetzen.
6. **iOS**: in `ios/Runner/AppDelegate.swift` ist kein Code nötig
   (FlutterFire initialisiert selbst). Für Push/Apple-Login/Links
   `native/ios_Runner.entitlements.example` verwenden.
7. **Regeln & Functions deployen**:
   ```sh
   firebase deploy --only firestore:rules,storage,functions
   ```
8. **Anmeldung**: Cloud-Modus nur nach Login anbieten. Ohne Anmeldung
   liefert `FirestoreItemRepository.forCurrentUser()` `null` und die App
   bleibt lokal. Nach dem Login `DataRepository.instance.attach(AppMode.cloud)`
   bzw. `SettingsService.instance.setMode(AppMode.cloud)`.

## Architektur

```
Screens ──► DataRepository (Cache im Speicher, notifyListeners)
                 │  wählt Quelle nach AppMode
     ┌───────────┼──────────────┬───────────────────────┐
LocalItemRepo  DemoItemRepo   FirestoreItemRepo (cloud)
 (JSON-Datei)   (Assets)       (Firestore + Offline-Cache)
```

- **Modi**: `local` (Standard) · `demo` (Assets, nichts wird gespeichert,
  beim Neustart wieder der alte Modus) · `cloud`.
- **Wechsel lokal → Cloud**: Bilder mit `CloudImageStore.upload` hochladen,
  `imagePath` durch die URL ersetzen, dann
  `FirestoreItemRepository.importAll(items)`.
- **Caching**: Firestore-Offline-Cache für Daten, `cached_network_image`
  für Bilder, `CacheStore` (lib/core/services) für alles Übrige
  (z. B. Profile anderer Nutzer, berechnete Werte).
- **Effiziente Bilder**: Beim Auswählen auf 1080 px/JPEG 82 % reduziert,
  Anzeige nur in Darstellungsgröße dekodiert (`ResizeImage`), eindeutige
  Dateinamen (UUID) → unveränderliche URLs, lange Cache-Dauer.
- **Geteilte Daten**: siehe „Gruppen“ unten.

## Gruppen (Rollen, Einladungen, Umkreis, Push, Links)

Für Apps, in denen sich Nutzer zu Gruppen zusammenschließen (Team, Verein,
Gemeinde …). Umbenennen je App, z. B. `groups` → `teams`.

```
groups/{groupId}                 name, ownerId, createdAt, blockedUserIds
groups/{groupId}/members/{uid}   uid, role (owner|admin|member), joinedAt
groupInvites/{token}             groupId, expiresAt, maxUses, useCount, role, revoked
users/{uid}/fcmTokens/{token}    Push-Token je Gerät
```

- **Rollen**: Inhaber (genau einer), Admins, Mitglieder. Admins bearbeiten
  Gruppe und Inhalte und laden ein; nur der Inhaber ernennt Admins und
  löscht die Gruppe. Die Rolle ändert nur die Function `setGroupRole`.
- **Gruppe anlegen**: Gruppe und eigenen Mitgliedseintrag mit
  `role: 'owner'` in **einem** Batch schreiben (die Regeln prüfen das).
- **Einladungen**: Admins legen `groupInvites/{token}` an (max. 31 Tage).
  Eingelöst wird nur über `redeemGroupInvite` (prüft Ablauf, `maxUses`,
  Sperrliste, legt das Mitglied an, benachrichtigt die Admins). Einmal-Code,
  z. B. für einen neuen Verwalter: `maxUses: 1, role: GroupRole.admin`
  (nur der Inhaber darf Admin-Einladungen erstellen).
- **Links**: `GroupInviteLinks.host` und `appScheme` anpassen.
  `DeepLinkService.instance.start()` nach dem Start; die Oberfläche hört auf
  `pending`. Für https-Links App Links/Universal Links einrichten
  (`native/`), unter `/invite/<token>` eine Weiterleitungsseite hosten.
- **Umkreis**: Orte mit `geohash` (`Geo.encode`) und `location` speichern.
  Abfrage je Präfix aus `Geo.coveringPrefixes`, dann `withinRadius`.
  Orte von Nutzern nur vergröbert (`Geo.coarse`, ca. 5 × 5 km) oder gar
  nicht speichern.
- **Push**: Nach dem Anmelden `NotificationService.instance
  .registerCurrentUser()`, in `CloudSetup.init`
  `beforeSignOut.add(NotificationService.instance.unregisterCurrentUser);`
  (aus `firebase/auth_service.dart`). Senden nur aus Functions mit
  `notifyUsers(uids, texte, {screen})`.
- **Gruppenfelder** je App in `isValidGroup` (firestore.rules) ergänzen und
  die Regeltests in `rules_tests/` erweitern.

## Testen mit Emulatoren

```sh
firebase emulators:start
```
Im Client (nur Debug):
```dart
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
```
Android-Emulator: `10.0.2.2` statt `localhost` und im Debug-Manifest
`android:usesCleartextTraffic="true"`.
