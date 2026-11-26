/// Kategorie von Terminen und Ankündigungen.
///
/// Standard-Kategorien ([builtInIds]) gibt es überall, Name aus den
/// Übersetzungen. Jede Moschee kann eigene anlegen (Name, Farbe, Symbol).
class EventCategory {
  const EventCategory({
    required this.id,
    required this.colorValue,
    required this.icon,
    this.mosqueId,
    this.name,
  });

  final String id;

  /// `null` bei Standard-Kategorien.
  final String? mosqueId;

  /// Nur bei eigenen Kategorien; Standard-Namen kommen aus l10n.
  final String? name;
  final int colorValue;

  /// Schlüssel des Symbols (siehe `categoryIcons`).
  final String icon;

  static const info = 'info';
  static const event = 'event';
  static const cenaze = 'cenaze';
  static const course = 'course';
  static const festival = 'festival';
  static const youth = 'youth';
  static const builtInIds = [info, event, cenaze, course, festival, youth];

  bool get builtIn => mosqueId == null;

  EventCategory copyWith({String? name, int? colorValue, String? icon}) =>
      EventCategory(
        id: id,
        mosqueId: mosqueId,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        icon: icon ?? this.icon,
      );

  factory EventCategory.fromJson(Map<String, dynamic> json) => EventCategory(
    id: json['id'] as String,
    mosqueId: json['mosqueId'] as String?,
    name: json['name'] as String?,
    colorValue: _hex(json['color'] as String),
    icon: json['icon'] as String? ?? 'event',
  );

  static int _hex(String hex) =>
      0xFF000000 | int.parse(hex.replaceFirst('#', ''), radix: 16);
}
