"""Erzeugt assets/testdata/test_data.json.

Regionen und Orte: DITIB Landesjugendverband Württemberg (Regionenkarte).
Koordinaten: ungefähre Ortsmitte, nicht geprüft. Alle Termine, Texte und
Community-Beiträge sind erfunden. Zeitangaben relativ zu "jetzt"
(dayOffset, postedHoursAgo), damit die Testdaten nie veralten.

Aufruf: python3 tool/build_test_data.py
"""
import json
import os
import re

REGIONS = [
    (1, "#6E6E6E", [
        ("Bietigheim-Bissingen", 48.948, 9.133, "74321"), ("Eppingen", 49.137, 8.910, "75031"),
        ("Erdmannhausen", 48.942, 9.296, "71729"), ("Güglingen", 49.066, 9.000, "74363"),
        ("Gundelsheim", 49.283, 9.161, "74831"), ("Heilbronn", 49.142, 9.219, "74072"),
        ("Hemmingen", 48.866, 9.036, "71282"), ("Kirchheim / Neckar", 49.045, 9.143, "74366"),
        ("Kornwestheim", 48.862, 9.185, "70806"), ("Lauffen / Neckar", 49.076, 9.148, "74348"),
        ("Ludwigsburg", 48.897, 9.192, "71634"), ("Markgröningen", 48.905, 9.081, "71706"),
        ("Oberstenfeld", 49.026, 9.322, "71720"), ("Sachsenheim", 48.960, 9.065, "74343"),
        ("Vaihingen / Enz", 48.933, 8.957, "71665"),
    ]),
    (2, "#A3A3A3", [
        ("Crailsheim", 49.135, 10.071, "74564"), ("Gaildorf", 49.000, 9.770, "74405"),
        ("Lauda-Königshofen", 49.565, 9.705, "97922"), ("Öhringen", 49.200, 9.502, "74613"),
        ("Schwäbisch Hall", 49.112, 9.737, "74523"), ("Wertheim", 49.759, 9.517, "97877"),
    ]),
    (3, "#3F2DB0", [
        ("Ditzingen", 48.827, 9.067, "71254"), ("Filderstadt", 48.670, 9.220, "70794"),
        ("Herrenberg", 48.596, 8.870, "71083"), ("Leonberg", 48.800, 9.015, "71229"),
        ("Renningen", 48.766, 8.934, "71272"), ("Sindelfingen", 48.713, 9.003, "71063"),
        ("Stuttgart-Feuerbach", 48.811, 9.160, "70469"), ("Stuttgart-Vaihingen", 48.729, 9.108, "70563"),
        ("Waldenbuch", 48.638, 9.132, "71111"),
    ]),
    (4, "#22A95C", [
        ("Backnang", 48.947, 9.430, "71522"), ("Murrhardt", 48.980, 9.578, "71540"),
        ("Rudersberg", 48.885, 9.528, "73635"), ("Schorndorf", 48.806, 9.528, "73614"),
        ("Schwaikheim", 48.877, 9.350, "71409"), ("Urbach", 48.815, 9.577, "73660"),
        ("Waiblingen", 48.831, 9.317, "71332"), ("Welzheim", 48.876, 9.635, "73642"),
        ("Winnenden", 48.876, 9.398, "71364"),
    ]),
    (5, "#D9AE2B", [
        ("Aalen", 48.837, 10.093, "73430"), ("Bopfingen", 48.857, 10.353, "73441"),
        ("Ellwangen", 48.962, 10.131, "73479"), ("Heubach", 48.792, 9.934, "73540"),
        ("Neresheim", 48.755, 10.335, "73450"), ("Schwäbisch Gmünd", 48.799, 9.798, "73525"),
    ]),
    (6, "#E67E33", [
        ("Ebersbach / Fils", 48.716, 9.523, "73061"), ("Esslingen / Neckar", 48.742, 9.307, "73728"),
        ("Geislingen", 48.623, 9.830, "73312"), ("Göppingen", 48.703, 9.652, "73033"),
        ("Kirchheim / Teck", 48.648, 9.451, "73230"), ("Köngen", 48.682, 9.366, "73257"),
        ("Ostfildern", 48.722, 9.262, "73760"), ("Süßen", 48.680, 9.758, "73079"),
        ("Uhingen", 48.706, 9.588, "73066"), ("Wernau / Neckar", 48.689, 9.418, "73249"),
    ]),
    (7, "#E07A80", [
        ("Giengen / Brenz", 48.622, 10.244, "89537"), ("Heidenheim", 48.677, 10.153, "89518"),
        ("Langenau", 48.497, 10.120, "89129"), ("Lonsee", 48.543, 9.920, "89173"),
        ("Sontheim", 48.553, 10.290, "89567"),
    ]),
    (8, "#D93F44", [
        ("Bad Urach", 48.492, 9.400, "72574"), ("Dettingen / Erms", 48.530, 9.347, "72581"),
        ("Hohenstein", 48.330, 9.330, "72531"), ("Metzingen", 48.537, 9.284, "72555"),
        ("Münsingen", 48.413, 9.495, "72525"), ("Reutlingen", 48.491, 9.211, "72764"),
        ("Tübingen", 48.521, 9.057, "72070"),
    ]),
    (9, "#C95FB2", [
        ("Albstadt / Ebingen", 48.214, 9.023, "72458"), ("Albstadt / Tailfingen", 48.255, 9.019, "72461"),
        ("Haigerloch", 48.364, 8.805, "72401"), ("Hechingen", 48.352, 8.964, "72379"),
        ("Schömberg", 48.207, 8.758, "72355"), ("Winterlingen", 48.180, 9.115, "72474"),
    ]),
    (10, "#3D9BE0", [
        ("Biberach / Riss", 48.098, 9.788, "88400"), ("Blaubeuren", 48.412, 9.785, "89143"),
        ("Dietenheim", 48.212, 10.073, "89165"), ("Ehingen / Donau", 48.283, 9.725, "89584"),
        ("Erbach", 48.328, 9.888, "89155"), ("Kirchdorf / Iller", 48.076, 10.130, "88457"),
        ("Laichingen", 48.489, 9.687, "89150"), ("Laupheim", 48.229, 9.880, "88471"),
        ("Munderkingen", 48.235, 9.645, "89597"), ("Ulm / Donau", 48.398, 9.992, "89073"),
    ]),
    (11, "#7FC94F", [
        ("Bad Saulgau", 48.016, 9.500, "88348"), ("Bad Schussenried", 48.006, 9.659, "88427"),
        ("Mengen / Ennetach", 48.050, 9.330, "88512"), ("Meßkirch", 47.993, 9.112, "88605"),
        ("Pfullendorf", 47.924, 9.257, "88630"), ("Sigmaringen", 48.087, 9.217, "72488"),
        ("Überlingen", 47.768, 9.159, "88662"),
    ]),
    (12, "#7B52D9", [
        ("Bad Waldsee", 47.920, 9.754, "88339"), ("Bad Wurzach", 47.908, 9.896, "88410"),
        ("Friedrichshafen", 47.654, 9.479, "88045"), ("Isny", 47.692, 10.039, "88316"),
        ("Leutkirch", 47.826, 10.022, "88299"), ("Ravensburg", 47.782, 9.612, "88212"),
        ("Wangen", 47.686, 9.834, "88239"),
    ]),
]

def slug(name):
    s = name.lower()
    for a, b in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")

ABOUT = {
    "schorndorf": "Unsere Gemeinde in Schorndorf: tägliche Gebete, Koranunterricht für Kinder, Jugend- und Frauengruppe, Teestube. Gäste sind jederzeit willkommen.",
    "waiblingen": "Moschee und Begegnungsort in Waiblingen mit Kursen für Kinder und Erwachsene.",
    "winnenden": "Gemeinde in Winnenden – Gebete, Jugendarbeit und Kermes zweimal im Jahr.",
    "backnang": "DITIB-Gemeinde Backnang mit Vortragsreihe und Hausaufgabenhilfe.",
    "urbach": "Kleine, familiäre Gemeinde im Remstal.",
    "welzheim": "Gemeinde im Schwäbischen Wald.",
    "murrhardt": "Gemeinde in Murrhardt mit Hafızlık-Kurs.",
}

# Siegel/Merkmale: von der App-Leitung gepflegt, Texte je Sprache.
BADGES = [
    {"id": "verified", "color": "#2E9E5B", "icon": "verified",
     "name": {"de": "Verifiziert", "tr": "Doğrulanmış", "en": "Verified"},
     "description": {
         "de": "Die App-Leitung hat diese Moschee geprüft: Eintrag im Vereinsregister und Rückruf über die offizielle Telefonnummer. Die Inhalte pflegt die Moschee selbst.",
         "tr": "Uygulama yönetimi bu camiyi kontrol etti: dernek kaydı ve resmi telefon numarası üzerinden geri arama. İçerikleri cami kendisi düzenler.",
         "en": "The app team checked this mosque: entry in the register of associations and a call back via its official phone number. The mosque maintains its content itself."}},
    {"id": "accessible", "color": "#4F8EF7", "icon": "accessible",
     "name": {"de": "Barrierefrei", "tr": "Engelsiz", "en": "Accessible"},
     "description": {
         "de": "Stufenloser Zugang zum Gebetsraum (Angabe der Moschee).",
         "tr": "Namaz alanına basamaksız erişim (caminin beyanı).",
         "en": "Step-free access to the prayer hall (stated by the mosque)."}},
    {"id": "women_area", "color": "#AB47BC", "icon": "women",
     "name": {"de": "Frauenbereich", "tr": "Kadınlar bölümü", "en": "Women's area"},
     "description": {
         "de": "Eigener Gebetsraum für Frauen.",
         "tr": "Kadınlar için ayrı namaz alanı.",
         "en": "Separate prayer room for women."}},
    {"id": "parking", "color": "#78909C", "icon": "parking",
     "name": {"de": "Parkplätze", "tr": "Otopark", "en": "Parking"},
     "description": {
         "de": "Parkplätze direkt an der Moschee.",
         "tr": "Caminin hemen yanında park yeri.",
         "en": "Parking right at the mosque."}},
]
FEATURES = {
    "schorndorf": ["accessible", "women_area", "parking"],
    "waiblingen": ["women_area", "parking"],
    "backnang": ["accessible"],
    "winnenden": ["parking"],
}

# Eigene Kategorien einzelner Moscheen (neben den Standard-Kategorien).
CATEGORIES = [
    {"id": "schorndorf-frauen", "mosqueId": "schorndorf", "name": "Frauenkreis", "color": "#D81B60", "icon": "women"},
    {"id": "schorndorf-sport", "mosqueId": "schorndorf", "name": "Sport", "color": "#43A047", "icon": "sport"},
]

mosques = []
regions = []
for number, color, towns in REGIONS:
    regions.append({"number": number, "color": color})
    for name, lat, lng, plz in towns:
        mid = slug(name)
        m = {
            "id": mid,
            "name": f"DITIB {name}",
            "city": name,
            "postalCode": plz,
            "region": number,
            "lat": lat,
            "lng": lng,
            "association": "ditib",
        }
        if mid in ABOUT:
            m["about"] = ABOUT[mid]
        if mid == "schorndorf":
            m["fridayPrayer"] = "12:45"
        m["badges"] = ["verified"] + FEATURES.get(mid, [])
        mosques.append(m)

ids = {m["id"] for m in mosques}

# category: info | event | cenaze | course | festival | youth | eigene ID
announcements = [
    # Schorndorf (eigene Moschee)
    {"mosqueId": "schorndorf", "kind": "cenaze", "title": "Cenaze-Gebet", "body": "Unsere Schwester Hatice K. ist verstorben. Das Totengebet findet nach dem Mittagsgebet im Hof der Moschee statt. Allah rahmet eylesin.", "dayOffset": 1, "time": "12:45", "postedHoursAgo": 3},
    {"mosqueId": "schorndorf", "kind": "youth", "title": "Jugendabend: Quiz & Tee", "body": "Für alle zwischen 14 und 25. Wir spielen ein Quiz rund um Geschichte und Alltag, danach gibt es Tee und Simit.", "dayOffset": 2, "time": "19:00", "postedHoursAgo": 30},
    {"mosqueId": "schorndorf", "kind": "course", "title": "Koran-Kurs für Kinder (7–12 Jahre)", "body": "Jeden Samstag. Anmeldung beim Imam oder nach dem Freitagsgebet. Bitte Heft und Stift mitbringen.", "dayOffset": 3, "time": "10:00", "postedHoursAgo": 72},
    {"mosqueId": "schorndorf", "kind": "event", "title": "Kandil-Programm", "body": "Gemeinsames Gebet, Koranrezitation und kurzer Vortrag. Im Anschluss Lokma für alle.", "dayOffset": 6, "time": "19:30", "postedHoursAgo": 50},
    {"mosqueId": "schorndorf", "kind": "schorndorf-frauen", "title": "Frauenkreis: Tee & Gespräch", "body": "Offener Abend für Frauen jeden Alters. Diesmal zum Thema Erziehung im Alltag. Kinderbetreuung im Nebenraum.", "dayOffset": 5, "time": "18:00", "postedHoursAgo": 44},
    {"mosqueId": "schorndorf", "kind": "schorndorf-sport", "title": "Fußball-Abend", "body": "Halle der Grauhalde-Schule, Sportschuhe mitbringen. Ab 16 Jahren.", "dayOffset": 7, "time": "20:00", "postedHoursAgo": 60},
    {"mosqueId": "schorndorf", "kind": "festival", "title": "Kermes – Winterbasar", "body": "Gözleme, Lahmacun, Baklava und Çay. Kinderprogramm im Gemeindesaal. Der Erlös geht an die Renovierung der Waschräume.", "dayOffset": 10, "time": "11:00", "postedHoursAgo": 120},
    {"mosqueId": "schorndorf", "kind": "info", "title": "Hac kayıtları 2027 başladı", "body": "2027 Hac organizasyonu için kayıtlar başladı. Bilgi ve kayıt için cemaat başkanlığına başvurabilirsiniz.", "postedHoursAgo": 20},
    {"mosqueId": "schorndorf", "kind": "info", "title": "Spendenaufruf: Renovierung der Waschräume", "body": "Die Waschräume werden im Frühjahr erneuert. Spenden sind über das Gemeindekonto oder bei der Kermes möglich.", "postedHoursAgo": 110},
    # Umgebung
    {"mosqueId": "backnang", "kind": "cenaze", "title": "Cenaze namazı", "body": "Kardeşimiz Mustafa A. vefat etmiştir. Cenaze namazı öğle namazına müteakip kılınacaktır.", "dayOffset": 0, "time": "13:00", "postedHoursAgo": 5},
    {"mosqueId": "backnang", "kind": "event", "title": "Vortrag: Islam und Umweltschutz", "body": "Vortrag mit anschließender Diskussion, auf Deutsch. Eintritt frei.", "dayOffset": 3, "time": "19:00", "postedHoursAgo": 40},
    {"mosqueId": "waiblingen", "kind": "festival", "title": "Tag der offenen Moschee", "body": "Führungen um 11, 13 und 15 Uhr, Ausstellung zur Geschichte der Gemeinde, Tee und Gebäck.", "dayOffset": 5, "time": "10:00", "postedHoursAgo": 60},
    {"mosqueId": "waiblingen", "kind": "course", "title": "Türkisch für Kinder", "body": "Neuer Kurs für Anfänger, 6–10 Jahre. Freie Plätze vorhanden.", "dayOffset": 4, "time": "15:00", "postedHoursAgo": 90},
    {"mosqueId": "winnenden", "kind": "festival", "title": "Kermes", "body": "Hausgemachtes Essen, Bücherstand und Hüpfburg für Kinder.", "dayOffset": 12, "time": "11:00", "postedHoursAgo": 100},
    {"mosqueId": "urbach", "kind": "event", "title": "Frauenfrühstück", "body": "Gemeinsames Frühstück und Austausch. Bitte bis Freitag anmelden.", "dayOffset": 4, "time": "09:30", "postedHoursAgo": 26},
    {"mosqueId": "welzheim", "kind": "youth", "title": "Familienwanderung am Ebnisee", "body": "Treffpunkt Parkplatz Ebnisee. Picknick bitte selbst mitbringen, Tee gibt es von uns.", "dayOffset": 8, "time": "10:30", "postedHoursAgo": 70},
    {"mosqueId": "murrhardt", "kind": "festival", "title": "Hafızlık icazet merasimi", "body": "Hafızlığını tamamlayan öğrencilerimiz için icazet merasimi. Tüm cemaatimiz davetlidir.", "dayOffset": 14, "time": "14:00", "postedHoursAgo": 140},
    {"mosqueId": "schwaikheim", "kind": "course", "title": "Hausaufgabenhilfe", "body": "Montags und mittwochs für Grundschulkinder, kostenlos.", "dayOffset": 5, "time": "15:30", "postedHoursAgo": 160},
    {"mosqueId": "rudersberg", "kind": "event", "title": "Gemeinsames Fastenbrechen (Freiwilliges Fasten)", "body": "Wer am Donnerstag freiwillig fastet, ist zum gemeinsamen Iftar eingeladen.", "dayOffset": 1, "time": "16:45", "postedHoursAgo": 22},
    {"mosqueId": "esslingen-neckar", "kind": "festival", "title": "Kermes", "body": "Großer Wohltätigkeitsbasar in Esslingen.", "dayOffset": 9, "time": "11:00", "postedHoursAgo": 80},
    {"mosqueId": "ludwigsburg", "kind": "festival", "title": "Kinderfest", "body": "Spiele, Kinderschminken und Theater für Kinder bis 12.", "dayOffset": 6, "time": "14:00", "postedHoursAgo": 75},
    {"mosqueId": "goeppingen", "kind": "event", "title": "Vortrag: Ehrenamt in der Gemeinde", "body": "Wie kann ich mich einbringen? Infoabend mit dem Vorstand.", "dayOffset": 7, "time": "19:30", "postedHoursAgo": 65},
    {"mosqueId": "schwaebisch-gmuend", "kind": "youth", "title": "Fußballturnier der Jugend", "body": "Teams aus der ganzen Region, Anmeldung bis Mittwoch.", "dayOffset": 11, "time": "09:00", "postedHoursAgo": 95},
]
category_ids = {"info", "event", "cenaze", "course", "festival", "youth"} | {c["id"] for c in CATEGORIES}
for i, a in enumerate(announcements):
    assert a["mosqueId"] in ids, a["mosqueId"]
    a["category"] = a.pop("kind")
    assert a["category"] in category_ids, a["category"]
    a["id"] = f"a{i + 1}"

# kind: offer | request
posts = [
    {"kind": "offer", "category": "education", "title": "Nachhilfe Mathe & Physik (Klasse 5–10)", "body": "Ich studiere Maschinenbau und gebe gern Nachhilfe, bei euch zu Hause oder in der Moschee. Kostenlos für Gemeindemitglieder.", "author": "Yusuf", "mosqueId": "schorndorf", "postedHoursAgo": 3, "interest": 2},
    {"kind": "request", "category": "children", "title": "Babysitter für Dienstagabend gesucht", "body": "Für zwei Kinder (4 und 7 Jahre), ca. 18–21 Uhr, alle zwei Wochen. Gerne mit Erfahrung.", "author": "Ayşe", "mosqueId": "schorndorf", "postedHoursAgo": 26, "interest": 1},
    {"kind": "offer", "category": "moving", "title": "Helfe beim Umzug – habe einen Transporter", "body": "Samstags meistens frei. Kraftstoff bitte übernehmen, sonst kostenlos.", "author": "Mehmet", "mosqueId": "waiblingen", "postedHoursAgo": 50, "interest": 4},
    {"kind": "offer", "category": "repair", "title": "3D-Druck: Ersatzteile & Halterungen", "body": "Abgebrochener Griff, fehlende Halterung? Ich drucke sie euch. Foto oder Maße per Nachricht.", "author": "Yusuf", "mosqueId": "winnenden", "postedHoursAgo": 5, "interest": 0},
    {"kind": "request", "category": "transport", "title": "Fahrgemeinschaft zum Freitagsgebet ab Urbach", "body": "Ich habe kein Auto mehr und würde mich gern einer Fahrgemeinschaft nach Schorndorf anschließen.", "author": "Hasan", "mosqueId": "urbach", "postedHoursAgo": 22, "interest": 1},
    {"kind": "offer", "category": "giveaway", "title": "Kinderbett und Hochstuhl zu verschenken", "body": "Gut erhalten, Abholung in Backnang.", "author": "Elif", "mosqueId": "backnang", "postedHoursAgo": 75, "interest": 3},
    {"kind": "request", "category": "accompany", "title": "Doktora refakat ve tercüme", "body": "Annem için perşembe sabahı doktor randevusuna refakat ve tercüme edecek birini arıyorum.", "author": "Fatma", "mosqueId": "schorndorf", "postedHoursAgo": 6, "interest": 0},
    {"kind": "offer", "category": "education", "title": "Hausaufgabenhilfe Deutsch für Grundschüler", "body": "Zwei Nachmittage pro Woche, in Waiblingen.", "author": "Zeynep", "mosqueId": "waiblingen", "postedHoursAgo": 48, "interest": 2},
    {"kind": "request", "category": "repair", "title": "Wer kann eine Waschmaschine anschließen?", "body": "Neue Waschmaschine ist da, aber der Anschluss passt nicht. Wer kennt sich aus?", "author": "Ali", "mosqueId": "rudersberg", "postedHoursAgo": 96, "interest": 1},
    {"kind": "offer", "category": "accompany", "title": "Smartphone-Hilfe für Senioren", "body": "WhatsApp, Fotos, Termine: Ich erkläre es in Ruhe, auf Deutsch oder Türkisch. Nach dem Mittagsgebet in der Teestube.", "author": "Elif", "mosqueId": "schorndorf", "postedHoursAgo": 28, "interest": 5},
    {"kind": "request", "category": "moving", "title": "Taşınma için yardım lazım (Cumartesi)", "body": "Cumartesi günü 3. kattan eşya taşımak için 2–3 kişiye ihtiyacımız var.", "author": "Murat", "mosqueId": "backnang", "postedHoursAgo": 12, "interest": 2},
    {"kind": "offer", "category": "other", "title": "Gartenarbeit – helfe gern am Wochenende", "body": "Hecke schneiden, Laub, Rasen. Für ältere Gemeindemitglieder gern ohne Gegenleistung.", "author": "Burak", "mosqueId": "welzheim", "postedHoursAgo": 120, "interest": 1},
]
for i, p in enumerate(posts):
    assert p["mosqueId"] in ids, p["mosqueId"]
    p["id"] = f"p{i + 1}"

data = {
    "_info": "Testdaten. Regionen und Orte nach der Regionenkarte des DITIB Landesjugendverbands Württemberg; Koordinaten ungefähr (Ortsmitte); alle Termine, Texte und Beiträge erfunden. Erzeugt mit tool/build_test_data.py.",
    "defaultMyMosques": ["schorndorf"],
    "regions": regions,
    "badges": BADGES,
    "categories": CATEGORIES,
    "mosques": mosques,
    "announcements": announcements,
    "communityPosts": posts,
}
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = os.path.join(root, "assets", "testdata", "test_data.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=1)
print(f"{len(regions)} Regionen, {len(mosques)} Moscheen, {len(announcements)} Termine/Ankündigungen, {len(posts)} Beiträge -> {out}")
