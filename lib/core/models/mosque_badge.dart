/// Siegel/Merkmal einer Moschee (z. B. „Verifiziert“, „Barrierefrei“).
/// Wird von der App-Leitung gepflegt; Texte je Sprache aus den Daten.
class MosqueBadge {
  const MosqueBadge({
    required this.id,
    required this.colorValue,
    required this.icon,
    required this.names,
    required this.descriptions,
  });

  static const verified = 'verified';

  final String id;
  final int colorValue;

  /// Schlüssel des Symbols (siehe `badgeIcons`).
  final String icon;

  /// Sprachcode → Text.
  final Map<String, String> names;
  final Map<String, String> descriptions;

  String name(String lang) => names[lang] ?? names['de'] ?? id;
  String description(String lang) =>
      descriptions[lang] ?? descriptions['de'] ?? '';

  factory MosqueBadge.fromJson(Map<String, dynamic> json) => MosqueBadge(
    id: json['id'] as String,
    colorValue:
        0xFF000000 |
        int.parse((json['color'] as String).replaceFirst('#', ''), radix: 16),
    icon: json['icon'] as String? ?? 'verified',
    names: (json['name'] as Map).cast<String, String>(),
    descriptions: (json['description'] as Map).cast<String, String>(),
  );
}
