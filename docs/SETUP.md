# Einrichtung für Entwickler

Schritt für Schritt vom leeren Rechner bis zur laufenden App und zum
Release-Build. Was die App ist und kann: [README.md](../README.md).

## 1. Voraussetzungen

Benötigt werden **Git** und das **Flutter-SDK (stable)**. Die App
verlangt Dart `^3.8.1` (`pubspec.yaml`), also **Flutter 3.32 oder neuer**.
Empfohlen ist **Flutter 3.47.2**, dieselbe Version wie in der CI. Ab 3.50
meldet `flutter analyze` `package:flutter/material.dart` als veraltet
(Ersatz: `material_ui`), die Umstellung steht noch aus.

**macOS**

1. Git: `xcode-select --install` (bringt Git mit) oder `brew install git`.
2. Flutter: `brew install --cask flutter`, oder das SDK von
   <https://docs.flutter.dev/get-started/install/macos> entpacken und
   `<pfad>/flutter/bin` in `~/.zshrc` zum `PATH` hinzufügen.
3. Prüfen: `flutter --version` und `flutter doctor`.

**Windows**

1. Git: <https://git-scm.com/download/win> installieren.
2. Flutter: SDK von <https://docs.flutter.dev/get-started/install/windows>
   nach z. B. `C:\dev\flutter` entpacken (kein Pfad mit Leerzeichen oder
   unter `C:\Program Files`), `C:\dev\flutter\bin` in die
   Umgebungsvariable `Path` eintragen.
3. Neues Terminal öffnen, dann `flutter --version` und `flutter doctor`.

## 2. IDE

- **VS Code** (empfohlen): Erweiterungen „Flutter“ und „Dart“ (Dart-Code)
  installieren. Gerät unten rechts in der Statusleiste wählen, mit `F5`
  starten.
- **Alternativ Android Studio**: unter *Settings → Plugins* das Plugin
  „Flutter“ installieren (bringt „Dart“ mit).

## 3. Android

1. **Android Studio** installieren: <https://developer.android.com/studio>.
2. Beim ersten Start den Assistenten durchlaufen; unter
   *Settings → Languages & Frameworks → Android SDK* sicherstellen:
   - *SDK Platforms*: aktuelles Android (die App nutzt Flutters
     Standardwerte für `compileSdk`/`targetSdk`)
   - *SDK Tools*: Android SDK Command-line Tools, Build-Tools,
     Platform-Tools, Emulator, **NDK (Side by side) 29.0.13599879**
     (fest eingetragen in `android/app/build.gradle.kts`)
3. Lizenzen annehmen: `flutter doctor --android-licenses`
4. **Emulator**: *Device Manager → Create Virtual Device*, z. B. Pixel,
   aktuelles System-Image, dann ▶ starten. Oder im Terminal:
   `flutter emulators` und `flutter emulators --launch <id>`.
5. Echtes Gerät: Entwickleroptionen und USB-Debugging aktivieren, per USB
   verbinden, `flutter devices` zeigt es an.

Das Projekt nutzt Gradle 9.1, Android Gradle Plugin 9.0 und Java 11 als
Zielversion. Android Studio bringt ein passendes JDK mit.

## 4. iOS (nur macOS)

1. **Xcode** aus dem App Store installieren, einmal öffnen, Zusatzkomponenten
   installieren lassen, dann:
   ```sh
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
2. **CocoaPods**: `brew install cocoapods` (oder `sudo gem install cocoapods`).
3. **Simulator**: `open -a Simulator`. Weitere Geräte unter
   *Xcode → Settings → Components* bzw. *Window → Devices and Simulators*.
4. Mindestversion der App: **iOS 15.6** (`ios/Podfile`).

> **Windows:** iOS-Apps lassen sich unter Windows nicht bauen. Dafür einen
> Cloud-Dienst mit macOS-Rechnern nutzen, z. B. **Codemagic**.

## 5. Projekt starten

```sh
git clone <repo-url>
cd ditib-app
flutter pub get
flutter gen-l10n     # erzeugt lib/core/l10n/app_localizations*.dart
flutter devices      # angeschlossene Geräte und laufende Emulatoren
flutter run          # fragt nach dem Gerät, wenn mehrere da sind
```

Gezielt starten: `flutter run -d <geräte-id>`. Während die App läuft:
`r` = Hot Reload, `R` = Hot Restart, `q` = beenden.

Beim ersten Start kommen Splash und Einführung, danach die App mit den
Testdaten (`assets/testdata/test_data.json`). Einführung erneut ansehen:
*Einstellungen (Zahnrad) → Einführung ansehen*. Die Datenquelle (Testdaten
oder Cloud) steht ebenfalls dort; Cloud ist erst nach dem Einbau wählbar.

## 6. Qualität

Vor jedem Commit:

```sh
flutter analyze && flutter test
```

Die **CI** (`.github/workflows/ci.yml`) läuft bei jedem Push auf `main` und
bei Pull Requests, mit Flutter 3.47.2 (fest eingetragen) unter Ubuntu:
`flutter pub get` → `flutter gen-l10n` → `flutter analyze` → `flutter test`.
Schlägt einer davon fehl, ist der Lauf rot.

Lint-Regeln stehen in `analysis_options.yaml`. `cloud_template/` wird dabei
nicht geprüft (siehe dessen README).

## 7. Alltag

**Neue Texte**

1. In `lib/core/l10n/app_de.arb` eintragen (Vorlage, mit `@`-Beschreibung
   bei Platzhaltern), dann dieselben Schlüssel in `app_en.arb` und
   `app_tr.arb`.
2. `flutter gen-l10n` ausführen.
3. Im Code: `AppLocalizations.of(context)!.mein_text`.
   Die generierten `app_localizations*.dart` nie von Hand bearbeiten.

**App-Icon und Splash**

1. `assets/icon/app_icon.png` ersetzen (quadratisch, mind. 1024 × 1024).
   Hintergrundfarbe ggf. in `pubspec.yaml` unter `flutter_launcher_icons`
   und `flutter_native_splash` anpassen.
2. Neu erzeugen:
   ```sh
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

**App-Icon neu zeichnen** (statt Bild ersetzen)

`flutter test tool/generate_app_icon_test.dart` erzeugt
`assets/icon/app_icon.png` und den Android-Vordergrund, danach
`dart run flutter_launcher_icons`.

**Testdaten ändern**

In `tool/build_test_data.py` bearbeiten, dann `python3 tool/build_test_data.py`.
Termine stehen dort relativ zu heute (`dayOffset`), damit sie nie veralten.

**Bausteine**

Die Komponenten-Galerie der Vorlage ist hier entfernt. Alle Bausteine aus
`lib/shared/widgets` lassen sich in der App-Vorlage im Tab *Komponenten*
ansehen.

## 8. Cloud (optional)

Firebase, Anmeldung, Gruppen, Push und Einladungslinks werden erst bei
Bedarf eingebaut: [cloud_template/README.md](../cloud_template/README.md).

## 9. Release-Builds

Version in `pubspec.yaml` erhöhen (`version: 1.0.1+2`, die Zahl hinter `+`
muss bei jedem Upload steigen).

**Android (App Bundle für Google Play)**

1. Einmalig einen Upload-Schlüssel erzeugen und **sicher außerhalb des
   Projekts** aufbewahren:
   ```sh
   keytool -genkey -v -keystore ~/keys/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. `android/key.properties` anlegen:
   ```properties
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=/Users/<name>/keys/upload-keystore.jks
   ```
   **Nie committen.** `key.properties`, `*.jks` und `*.keystore` stehen in
   `android/.gitignore`. Ohne die Datei signiert der Build mit dem
   Debug-Schlüssel, das geht nur zum Testen.
3. Bauen: `flutter build appbundle` → Ergebnis unter
   `build/app/outputs/bundle/release/app-release.aab`, in der Play Console
   hochladen.

**iOS (App Store / TestFlight)**

1. `flutter build ios --release` (oder direkt in Xcode bauen).
2. `ios/Runner.xcworkspace` in Xcode öffnen (nicht `.xcodeproj`), unter
   *Runner → Signing & Capabilities* das Team wählen.
3. Als Ziel *Any iOS Device (arm64)* wählen, dann
   *Product → Archive* → *Distribute App* → App Store Connect.

## 10. Häufige Probleme

| Problem | Lösung |
|---|---|
| Unklar, was fehlt | `flutter doctor -v` und die markierten Punkte abarbeiten |
| Seltsame Build-Fehler nach Paket- oder Branch-Wechsel | `flutter clean && flutter pub get && flutter gen-l10n` |
| `AppLocalizations` oder ein Text nicht gefunden | `flutter gen-l10n` |
| iOS: Pod-Fehler, „module not found“ | `cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ..` |
| Android: Lizenzen nicht akzeptiert | `flutter doctor --android-licenses` |
| Android: NDK fehlt | NDK 29.0.13599879 im SDK Manager installieren |
| Gerät wird nicht angezeigt | `flutter devices`; Emulator/Simulator vorher starten, bei USB-Geräten Debugging erlauben |
