# Muslim-Community-App – Recherche & Konzept

Stand: Nov 25, 2026 · Erste Ausarbeitung zu euren Notizen. Rechtliche Hinweise sind eine Orientierung, keine Rechtsberatung.

## 1. Kurzfazit

- **Es gibt viele Gebetszeiten-Apps und einige Moschee-Apps, aber keine, die in Deutschland verbandsübergreifend Moscheen in einem Umkreis bündelt und gleichzeitig eine Hilfebörse für die Gemeinde bietet.** Genau da liegt eure Lücke. Am nächsten kommt die Cuma-App, aber die ist ein allgemeines soziales Netzwerk mit Marktplatz, nicht die Plattform der Moscheen selbst.
- Der stärkste vorhandene Player ist **MAWAQIT** (kostenlos, Waqf-Modell, Moscheen pflegen ihre Zeiten und Ankündigungen selbst). Den solltet ihr genau anschauen – als Vorbild und als Konkurrenz.
- **Für alle Moscheen offen, nicht nur DITIB**: das passt zum Community-Gedanken. Mit Verbands-Kennzeichnung und Filter bleibt es trotzdem übersichtlich. Für den Start eignet sich ein Pilot mit wenigen DITIB-Gemeinden, die ihr schon kennt.
- **Technik: Flutter.** Das kennst du schon, und für Android und iOS aus einer Codebasis ist es weiterhin eine der besten Optionen.
- **Backend: Firebase ist für den Start okay, aber nur hinter einer eigenen Service-Schicht.** Supabase ist eine ernsthafte Alternative, weil es Open Source und selbst hostbar ist und Umkreissuchen (PostGIS) besser kann.
- **Datenschutz ist der größte Knackpunkt:** Schon die Nutzung einer Moschee-App kann die Religionszugehörigkeit verraten. Das ist eine besondere Datenkategorie nach Art. 9 DSGVO. Deshalb: so wenig Daten wie möglich, EU-Server, Mitgliedschaft und Zahlungen erst später.
- **Hilfebörse im ersten Schritt nur mit Text, ohne Bilder und ohne freien Chat.** Das senkt den Moderations- und Rechtsaufwand stark (Details in Abschnitt 8).

## 2. Marktrecherche: was es schon gibt

| App | Was sie kann | Relevanz für euch |
| --- | --- | --- |
| **MAWAQIT** | Moscheen pflegen Gebets- und Iqama-Zeiten selbst, Ankündigungen, Qibla-Kompass, Karte mit Moscheen in der Nähe, Koran/Azkar. Kostenlos als Waqf, kommerzielle Nutzung verboten. Neue Moscheen werden moderiert. | Hauptkonkurrent bei Zeiten und Ankündigungen. Sehr gutes Vorbild für Onboarding und Verifizierung von Moscheen. Keine Hilfebörse und kaum Community-Funktionen. |
| **Masjidbox** (z. B. IZ Wien, ELIF, IKRE, Wissensoase) | White-Label: jede Moschee bekommt eine eigene App mit Zeiten, Iqama, Ankündigungen, News, Events, Medien, Umfragen. | Zeigt den Bedarf. Nachteil: eine App pro Moschee, also kein Umkreis und kein Netzwerk. |
| **moschee.io** (Youcci UG) | Neue Plattform „die digitale Moschee“: Gebetszeiten, Benachrichtigungen, Livestream, Deutsch/Türkisch/Französisch. | Direkter, junger Konkurrent aus Deutschland. Beobachten. |
| **IGMG-App** | Gebetszeiten, nächste IGMG-Moschee, Qibla, Ezan, Freitagspredigten. | Verbands-App, nur IGMG. Zeigt, dass Verbände eigene Apps machen. |
| **DITIB: „DiTiB Veli“ / „eDitib“** | Schülerregistrierung und Kursverfolgung (Eltern-Sicht). Vermutlich gehört die Anwesenheitserfassung aus Nürnberg dazu. | Keine Community-App, eher Kursverwaltung. Mögliche spätere Schnittstelle, kein Konkurrent. Eine allgemeine DITIB-Gemeinde-App habe ich nicht gefunden. |
| **Islam Kassel** | Alle Moscheen einer Stadt, eigene Gemeinde wählen, Zeiten der anderen sehen, News-Feed. | Sehr nah an eurer Umkreis-Idee, aber nur lokal für eine Stadt. |
| **Islam.app, Ibadat u. Ä.** | Gebetszeiten, Qibla, Koran, Tracker. | Das sind die „schlechteren Apps“, die ihr ablösen wollt. Kein Moschee-Bezug. |
| **Communi, KirchApp, meinegemeinde.digital** (Kirchen) | Gemeinde-Apps mit schwarzem Brett: Mitglieder posten, was sie suchen oder anbieten. Dazu Termine, Gemeindebriefe, Umfragen, Spenden. | Bestes Vorbild für die Hilfebörse und die Admin-Oberfläche. Lohnt sich zum „Abgucken“ bei Onboarding, Rollen und Benachrichtigungen. |
| **„Cuma-App“** | Soziales Netzwerk für die muslimische Community (Betreiber: Privatperson aus Filderstadt): Beiträge, Stories, Lives, Chats und Anrufe, Gruppen, Events, Marktplatz mit Shop-Anbindung, Moscheefinder, Gebetszeiten. Finanziert über Abos (Pro/Business). Backend: Firebase mit Server-Funktionen in Frankfurt. | Konkurrent bei Community und Hilfe/Marktplatz, aber ohne von Moscheen verwaltete Seiten und ohne Verifizierung. Eher Instagram-artig und kommerziell. Gute Vorlage für eure Nutzungsbedingungen: Mindestalter 16, Prüfung von Meldungen binnen 24 Stunden, Verträge nur zwischen den Nutzern. |

**Zum Abgucken (Onboarding, Account, Profilangaben):** MAWAQIT (Moschee auswählen statt Registrierung erzwingen) und Communi/KirchApp (Beitrittsanfrage an die Gemeinde, Push-Einstellungen pro Kategorie). Gute Praxis: Die App ist **ohne Account nutzbar** (Zeiten, Qibla, Ankündigungen lesen). Ein Account wird erst zum Posten in der Hilfebörse nötig. Das senkt die Einstiegshürde und die Datenmenge.

**Warum sollten Leute eure App nutzen?**

- Alle Moscheen in der Umgebung in einer App, auch verbandsübergreifend.
- Verlässliche Zeiten direkt von der eigenen Moschee, plus Kompass, ohne Werbung.
- Push-Nachrichten bei Cenaze-Gebeten, Kursen und Festen.
- Die Hilfebörse als echtes Alleinstellungsmerkmal.
- Deutsch und Türkisch (später Arabisch u. a.).

**Karte:** Gibt es bei MAWAQIT schon. Bei euch ist sie trotzdem sinnvoll, weil sie zur Umkreis-Auswahl gehört. Umsetzung kostenlos mit OpenStreetMap (flutter\_map) statt Google Maps.

## 3. Strategische Grundsatzfragen

**Nur DITIB oder alle Moscheen?** Empfehlung: offen für alle. Jede Moschee hat ein Feld „Verband“ (DITIB, IGMG, VIKZ, ZMD, unabhängig …). Nutzer können danach filtern. So vermeidet ihr eine Spaltung, könnt aber im Pilot mit DITIB-Gemeinden starten. Wichtig: das Datenmodell von Anfang an so bauen, dann ist es später nur noch eine Freigabe-Entscheidung.

**Wer darf ein Moschee-Konto erstellen? Vorschlag für die Verifizierung:**

1. Die Moschee stellt in der App oder auf einer Webseite einen Antrag: Name, Adresse, Verband, Ansprechperson.
2. Ihr prüft: Eintrag im Vereinsregister, Impressum oder Website, Rückruf über die **offizielle** Telefonnummer der Moschee (nicht über die Nummer aus dem Antrag). Bei DITIB evtl. Bestätigung über den Landesverband.
3. Ihr schickt einen **einmaligen, zeitlich begrenzten Einladungscode** an die offizielle Adresse oder per Post an die Moschee.
4. Mit dem Code wird das Inhaber-Konto erstellt. Der Inhaber lädt selbst Admins und Redakteure ein.
5. Rollen: Inhaber (kann alles, auch Admins entfernen), Admin (Inhalte und Termine), Redakteur (nur Beiträge). Plus ein Plattform-Admin (ihr) für Sperren und Streitfälle.

## 4. Funktionsumfang und Phasen

| Phase | Funktionen |
| --- | --- |
| **MVP** | Moschee-Seiten, Ankündigungen und Termine (Cenaze, Kurse, Feste), Push, eigene Moschee plus Umkreis oder manuelle Auswahl, Gebetszeiten, Qibla-Kompass, Karte, Admin-Bereich, Verifizierung |
| **Phase 2** | Hilfebörse (Text, Kategorien, „Interesse melden“), Melde-Funktion, Moderation, Mehrsprachigkeit |
| **Phase 3** | Mitglieds-Siegel (vom Moschee-Admin bestätigt), Umfragen, Kursanmeldung, evtl. Anwesenheit |
| **Später** | Digitale Briefe, Beitragsübersicht, Social-Media-Inhalte (Bilder, Videos) |

**Gebetszeiten:** Zwei Wege kombinieren. (a) Lokale Berechnung mit dem Paket `adhan` (Dart), Methode einstellbar, auch die türkische Diyanet-Methode. (b) Wenn die Moschee eigene Zeiten oder Iqama-Zeiten pflegt, haben die Vorrang. So macht es auch MAWAQIT, und genau das macht die Zeiten verlässlich.

**Mitgliederbereich:** Mitgliedslisten, Zahlungen und Briefe sind besonders sensibel (Religion nach Art. 9 DSGVO plus Finanzdaten). Außerdem verwaltet jede Moschee das anders. Empfehlung: zuerst nur ein **Siegel**. Der Nutzer stellt eine Anfrage, der Moschee-Admin bestätigt sie. Keine Anbindung an Mitgliederlisten. Digitale Briefe und Zahlungen erst, wenn ein Träger (Verein/Unternehmen) mit Datenschutzkonzept dahintersteht.

## 5. Entwicklung: Framework-Vergleich

| Option | Sprache | Vorteile | Nachteile | Passt zu euch? |
| --- | --- | --- | --- | --- |
| **Flutter** | Dart | Eine Codebasis, sehr konsistente UI, große Community, gute Firebase/Supabase-Pakete, du hast Erfahrung | Dart ist außerhalb von Flutter wenig verbreitet; App-Größe etwas höher | **Ja, Empfehlung** |
| **React Native (Expo)** | TypeScript | Riesiges JS-Ökosystem, Expo vereinfacht Builds | Neue Sprache und neues Ökosystem für dich, mehr Abhängigkeiten von Drittpaketen | Nur, wenn das Team JS-Erfahrung hat |
| **Kotlin/Compose Multiplatform** | Kotlin | Echte native Performance, Logik teilen, UI wahlweise teilen | iOS-Seite jünger, kleineres Ökosystem, steilere Lernkurve | Eher nicht für den Start |
| **.NET MAUI** | C# | Gut für C#-Teams | Kleinere Mobile-Community, UI-Probleme häufiger | Nein |
| **Nativ (Swift + Kotlin)** | 2 Sprachen | Beste Plattformintegration | Doppelter Aufwand | Nein (zu teuer für ein Ehrenamtsprojekt) |

Hinweise: Für iOS-Builds braucht ihr einen Mac oder einen Cloud-Build-Dienst (z. B. Codemagic mit Free-Tier). Das Apple-Developer-Programm kostet jährlich, Google Play einmalig. Apple hat eine Gebührenbefreiung für gemeinnützige Organisationen; ob sie in Deutschland gilt, solltet ihr prüfen, sobald ein Verein oder eine Organisation dahintersteht.

## 6. Architektur und Backend

**Ja, die Datenbank-Anbindung modular über Services/Repositories bauen.** Das ist der wichtigste Punkt für einen späteren Wechsel.

- **Struktur:** feature-first (z. B. `features/mosques`, `features/announcements`, `features/help_board`), darin die Schichten `presentation` → `domain` (Entities, Repository-Interfaces) → `data` (Firebase-Implementierung).
- **Abstraktion:** Für Auth, Datenbank, Storage und Push jeweils ein Interface, z. B. `AuthRepository` mit `FirebaseAuthRepository`. Die UI kennt nur das Interface. Später kommt `SupabaseAuthRepository` dazu, und ihr tauscht nur die Dependency-Injection aus.
- **State-Management und Routing:** Riverpod oder Bloc, dazu go\_router. Wichtig ist, sich auf eines festzulegen und das in einer kurzen Architektur-Doku (ADR) festzuhalten. Das erleichtert die Übergabe an ein neues Team.
- **Realistische Einschränkung:** Eine komplett anbieterneutrale Schicht ist mit Firestore schwer. Firestore ist dokumentbasiert, Supabase relational, Echtzeit und Sicherheitsregeln funktionieren unterschiedlich. Die Repository-Schicht hält die App sauber, aber die Datenmigration bleibt Arbeit.

**Firebase vs. Alternativen**

|  | Firebase | Supabase | Appwrite / PocketBase |
| --- | --- | --- | --- |
| Start-Geschwindigkeit | Sehr hoch | Hoch | Mittel |
| Selbst hostbar | Nein | Ja (Open Source) | Ja |
| Umkreissuche | Nur Umwege (Geohash) | Nativ mit PostGIS | Eingeschränkt |
| Datenmodell | Dokumente (NoSQL) | Postgres (SQL) | gemischt |
| Push | FCM (sowieso nötig) | FCM separat nutzen | FCM separat nutzen |
| EU-Region | wählbar | wählbar | selbst bestimmt |

**Empfehlung:** Wenn ihr ohnehin später selbst hosten wollt, startet direkt mit Supabase (gehostet in der EU-Region, später ohne Datenmodell-Bruch selbst hostbar). Wenn ihr bei Firebase bleibt: EU-Region wählen, Repository-Schicht strikt einhalten, für Push nutzt ihr FCM in beiden Fällen.

## 7. Tools (kostenlos / Open Source)

| Bereich | Schlanker Start | Optional, wenn das Projekt wächst |
| --- | --- | --- |
| Code + Aufgaben | GitHub (Repo, Issues, Projects-Board) | GitHub Actions für automatische Builds |
| Kommunikation | Discord | – |
| Meetings | Jitsi | – |
| Doku | Markdown-Dateien im Repo (`/docs`) | Docmost, wenn mehr Leute mitarbeiten |
| Diagramme | Mermaid im Repo (zeigt GitHub direkt an) | PlantUML |
| Design / Mockups | Penpot oder Figma Free | – |
| IDE | VS Code oder Android Studio mit Flutter-Plugin | – |
| iOS-Builds | Codemagic (Free-Tier) oder ein eigener Mac | – |
| Crash-Reports | – | Sentry oder Firebase Crashlytics |

Für ein kleines Team reicht die linke Spalte. Der Rest aus eurer Mindmap (LibreOffice, Freemind, PID, Gantt-Chart) lohnt sich erst, wenn das Projekt größer wird oder an ein neues Team geht.

## 8. Rechtliches: Hilfebörse

**Grundlage:** Sobald Nutzer Inhalte einstellen, die andere sehen, seid ihr Hosting-Anbieter und in der Regel eine „Online-Plattform“ nach dem **Digital Services Act (DSA)**. Der gilt seit Februar 2024 auch für kleine Anbieter. Kleinst- und Kleinunternehmen sind von einigen Pflichten befreit (z. B. Transparenzberichten), aber nicht von den Grundpflichten. Ob ein rein ehrenamtliches, kostenloses Angebot überhaupt unter den DSA fällt, ist umstritten. Spätestens wenn ein Unternehmen die App veröffentlicht, fällt sie darunter. Die Grundpflichten sind aber günstig umzusetzen, also baut sie von Anfang an ein.

**Pflichten, die ihr auf jeden Fall einplanen solltet:**

- Melde-Button für rechtswidrige Inhalte und ein Verfahren, um sie zu prüfen und zu entfernen (Notice & Action)
- Begründung an den Nutzer, wenn ihr einen Beitrag löscht oder ein Konto sperrt
- Nutzungsbedingungen mit klaren Regeln zur Moderation
- Kontaktstelle für Nutzer und Behörden
- Impressum und Datenschutzerklärung (auch in der App selbst)
- Mindestalter: Einwilligung in Deutschland erst ab 16 (Art. 8 DSGVO), also z. B. Posten erst ab 16 oder 18

**Besondere Risiken bei euren Beispielen:**

- **Babysitting und Nachhilfe:** Hier geht es um Kinder. Klar sagen, dass ihr nur vermittelt und nicht prüft. Hinweis, dass Eltern selbst prüfen müssen (z. B. erweitertes Führungszeugnis bei Betreuung). Keine Kinderfotos.
- **Gewerbliche Angebote:** Die Hilfebörse auf unentgeltliche Nachbarschaftshilfe beschränken oder gewerbliche Anzeigen kennzeichnen. Sonst bewegt ihr euch Richtung Marktplatz mit zusätzlichen Pflichten.
- **Haftung:** In den Nutzungsbedingungen festhalten, dass Absprachen nur zwischen den Nutzern zustande kommen.

**Vergleich der Varianten**

| Variante | Aufwand & Risiko | Bewertung |
| --- | --- | --- |
| **Nur Text** | Niedrig. Moderation per Textfilter und Meldungen gut machbar. | **Empfehlung für den Start** |
| **Text + Bilder** | Deutlich höher: Urheberrecht, Persönlichkeitsrechte (Personen und Kinder auf Fotos), Risiko illegaler Bilder. Braucht Bild-Moderation und Speicherkosten. | Später, evtl. nur für verifizierte Moscheen |
| **Reaktionen / „Interesse melden“** | Niedrig. Erst wenn beide zustimmen, werden Kontaktdaten (z. B. Telefonnummer) geteilt. | **Empfehlung als Kontaktweg** |
| **Freier Chat** | Hoch: Belästigung, Betrug, Kontakt Erwachsener zu Minderjährigen, Speicherung privater Nachrichten, Blockieren und Melden im Chat nötig. | Erst, wenn Moderation steht |
| **Abstimmungen / Kommentare öffentlich** | Mittel. Jeder Kommentar ist wieder ein moderationspflichtiger Inhalt. | Optional |

**Tipp:** Bevor die Hilfebörse live geht, Nutzungsbedingungen und Datenschutzerklärung einmal von einem Anwalt oder der Rechtsabteilung eines Verbands prüfen lassen. Bei Datenschutzfragen helfen oft auch die Landesdatenschutzbehörden mit Infomaterial.

## 9. Personas (Entwurf)

- **Hasan, 58, Vorstand einer DITIB-Gemeinde:** wenig technikaffin, will Cenaze- und Festtermine schnell an alle bringen und braucht eine einfache Admin-Oberfläche. Sprache: lieber Türkisch.
- **Elif, 24, Jugendbeauftragte:** pflegt Kurse und Events, wünscht sich Umfragen und Anmeldungen, nutzt Instagram und WhatsApp. Sie wäre eure typische Admin-Nutzerin.
- **Ayşe, 38, Mutter von zwei Kindern:** sucht Nachhilfe und bietet Babysitting an, will wissen, was in den Moscheen in der Nähe passiert. Achtet auf Sicherheit.
- **Yusuf, 21, Student, neu in der Stadt:** sucht Moscheen, Gebetszeiten, Kompass und Anschluss, hat einen 3D-Drucker und hilft gerne beim Umzug.
- **Mehmet Amca, 70:** möchte Gebetszeiten groß und lesbar sehen und über Cenaze-Gebete informiert werden. Braucht große Schrift und keinen Account.

## 10. App-Name: erste Ideen

Cemaat, Mahalle, Komşu, Halka, Rabita, Ummah Connect, CamiNet, Birlikte. Vor der Entscheidung prüfen: Gibt es den Namen schon in App Store oder Play Store, beim DPMA (Markenregister) und als Domain? Der Name sollte auf Deutsch und Türkisch funktionieren und nicht verbandsgebunden klingen.

## 11. Deine bestehenden Projekte und die App-Vorlage

Die App-Vorlage ist schon die gemeinsame Basis, die ich vorschlagen wollte. Login und Cloud liegen getrennt in `cloud_template/` und werden nicht mitkompiliert, und die Screens sprechen nur mit dem `DataRepository`. Es braucht also keine neue Vorlage. Es fehlt nur, die Verbesserungen aus Klangraum und der Cloud-App zurück in die Vorlage zu holen.

| Projekt | Umfang (Dart) | Was davon in die Vorlage gehört |
| --- | --- | --- |
| App-Vorlage | ca. 6.700 Zeilen | Basis: Theme, Widgets, `DataRepository` mit den Modi lokal/demo/cloud, `cloud_template/`, CI mit analyze und test |
| Klangraum | ca. 30.500 Zeilen | Neuere Theme-Fassung, überarbeitete Wisch-Aktionen und mehrere allgemeine Widgets (Details unten) |
| Cloud-App (Team-Manager) | ca. 56.000 Zeilen | Rollen, Einladungslinks, Umkreissuche, Push, Deep Links (Details unten) |

Dateien wie `app_design.dart`, `settings_tiles.dart` und `app_motion.dart` sind in allen drei Projekten identisch. Das Gerüst ist also schon einheitlich.

**Zurück in die Vorlage holen:**

1. **Theme aus Klangraum:** die Korrektur, damit Flutter nicht sein Standard-Türkis nutzt, runde Zurück- und Schließen-Buttons im Kopf, `AppSaveButton` und `AppBackButton`. Die Akzentfarben bleiben je App eigen.
2. **Wisch-Aktionen aus Klangraum** (`swipe_action_tile.dart`): begrenzte Breite auf Tablet und Mac, Beschriftungen werden nicht mehr abgeschnitten.
3. **Allgemeine Widgets aus Klangraum:** `AppToast`, `SlidingSegments`, `AppListRow`, `CollapsingHeader`, `PickField`, `SuggestField`, `AppScrollbar`, `SelectionBar`, dazu `format.dart` und `fuzzy.dart` (unscharfe Suche). Musik-Spezifisches wie Artwork, TrackTile oder KlangraumLogo bleibt draußen.
4. **In `cloud_template/` aus der Cloud-App:** Rollen Inhaber/Admin/Mitglied, Einladungslinks mit Ablaufdatum und maximaler Nutzung (eingelöst per Cloud Function), `geo.dart` für die Umkreissuche, `notification_service.dart` und `deep_link_service.dart`. Am besten als allgemeine „Gruppen“-Bausteine statt „Team“. Den `auth_service` abgleichen; er weicht nur um rund 20 Zeilen ab.

**Direkt für die Moschee-App nutzbar:** Team entspricht Moschee, Owner/Admin entspricht Inhaber/Admin. Der einmalige Verwalter-Code aus Abschnitt 3 ist ein Einladungslink mit maximal einer Nutzung. Die Geohash-Suche wird zum Umkreis, die Push-Nachrichten zu den Cenaze-Benachrichtigungen.

**Worauf achten:**

- `firestore_service.dart` der Cloud-App ist mit ca. 1.600 Zeilen ein Sammelbecken, und `socials_screen.dart` greift direkt auf Firestore zu. In der neuen App lieber pro Bereich ein Repository-Interface wie `TeamAccess`, und Firestore nur im Daten-Ordner.
- Teams werden aus Datenschutzgründen nur auf etwa 5 × 5 km genau gespeichert. Moscheen sind öffentliche Orte und dürfen genau gespeichert werden. Bei Nutzern bleibt es bei ungefähr oder gar nicht.
- Im Vorlage-Ordner liegen `.idea/` und `.github/java-upgrade/` (Reste einer VS-Code-Java-Erweiterung). Beides gehört nicht ins Repo: in die `.gitignore` aufnehmen bzw. löschen.

## 12. Lohnt sich graphify?

graphify erstellt aus einem Projektordner (Code, Doku, PDFs, Bilder) einen Wissensgraphen, den KI-Coding-Assistenten wie Claude Code abfragen können, statt alle Dateien zu durchsuchen. Code wird dabei strukturell analysiert, andere Dateien semantisch über ein Sprachmodell. Das kostet Tokens.

**Einschätzung:**

- **Für die Vorlage nützlich:** Einmal über deine zwei Apps und die Vorlage laufen lassen, um Gemeinsamkeiten und Abhängigkeiten zu sehen, bevor du sie zusammenführst.
- **Für die neue App am Anfang wenig Nutzen:** Ein junges, kleines Projekt überblickt der Assistent auch ohne Graph. Interessant wird es, wenn das Projekt wächst oder ein neues Team einsteigt.
- **Vorher prüfen,** ob Dart vom Code-Parser unterstützt wird. Sonst fällt der strukturelle Teil weg.

## 13. Nächste Schritte

1. Cuma-App selbst testen und die Unterschiede zu eurer Idee festhalten
2. Projektdateien schicken (siehe Abschnitt 11), dann Vorlage planen
3. Entscheiden: alle Moscheen oder nur DITIB, und Firebase oder Supabase
4. Mit 2–3 Moscheen sprechen: Was brauchen sie wirklich? (Personas überprüfen)
5. MVP-Screens in Penpot oder Figma skizzieren
6. Namensideen prüfen und auswählen
