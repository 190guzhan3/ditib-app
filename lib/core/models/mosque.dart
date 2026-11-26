/// Region eines Verbands (z. B. DITIB-Region 4 = Rems-Murr).
class MosqueRegion {
  const MosqueRegion({required this.number, required this.colorValue});

  final int number;

  /// Farbe aus der Regionenkarte (ARGB), Teil der Daten, nicht des Themes.
  final int colorValue;

  factory MosqueRegion.fromJson(Map<String, dynamic> json) => MosqueRegion(
    number: json['number'] as int,
    colorValue: _parseHex(json['color'] as String),
  );

  static int _parseHex(String hex) =>
      0xFF000000 | int.parse(hex.replaceFirst('#', ''), radix: 16);
}

/// Eine Moschee mit öffentlicher Seite. Moscheen sind öffentliche Orte und
/// dürfen genau verortet werden (Nutzer dagegen nicht).
class Mosque {
  const Mosque({
    required this.id,
    required this.name,
    required this.city,
    required this.postalCode,
    required this.region,
    required this.lat,
    required this.lng,
    required this.association,
    this.badges = const [],
    this.about,
    this.imagePath,
    this.fridayPrayer,
    this.phone,
    this.website,
  });

  final String id;
  final String name;
  final String city;
  final String postalCode;

  /// Regionsnummer im Verband, `null` wenn keine.
  final int? region;
  final double lat;
  final double lng;

  /// Verband als Schlüssel (`ditib`, `igmg`, `vikz`, `zmd`, `independent`).
  final String association;

  /// IDs der Siegel ([MosqueBadge]), vergeben von der App-Leitung.
  final List<String> badges;
  bool get verified => badges.contains('verified');
  final String? about;
  final String? imagePath;

  /// Uhrzeit des Freitagsgebets ("12:45"), von der Moschee gepflegt.
  final String? fridayPrayer;
  final String? phone;
  final String? website;

  /// Neue Fassung mit den Feldern, die die Moschee selbst pflegt
  /// (Verwaltung); `null` leert ein Feld. Name, Ort und Siegel ändert nur
  /// die App-Leitung.
  Mosque withPageInfo({
    required String? about,
    required String? imagePath,
    required String? fridayPrayer,
    required String? phone,
    required String? website,
  }) => Mosque(
    id: id,
    name: name,
    city: city,
    postalCode: postalCode,
    region: region,
    lat: lat,
    lng: lng,
    association: association,
    badges: badges,
    about: about,
    imagePath: imagePath,
    fridayPrayer: fridayPrayer,
    phone: phone,
    website: website,
  );

  factory Mosque.fromJson(Map<String, dynamic> json) => Mosque(
    id: json['id'] as String,
    name: json['name'] as String,
    city: json['city'] as String,
    postalCode: json['postalCode'] as String? ?? '',
    region: json['region'] as int?,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    association: json['association'] as String? ?? 'independent',
    badges: (json['badges'] as List? ?? const []).cast<String>(),
    about: json['about'] as String?,
    imagePath: json['imagePath'] as String?,
    fridayPrayer: json['fridayPrayer'] as String?,
    phone: json['phone'] as String?,
    website: json['website'] as String?,
  );
}
