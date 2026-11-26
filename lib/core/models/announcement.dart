/// Ankündigung oder Termin einer Moschee. Ohne [start] ein reiner Hinweis.
class Announcement {
  const Announcement({
    required this.id,
    required this.mosqueId,
    required this.categoryId,
    required this.title,
    required this.body,
    required this.postedAt,
    this.start,
  });

  final String id;
  final String mosqueId;

  /// ID einer [EventCategory] (Standard oder eigene der Moschee).
  final String categoryId;
  final String title;
  final String body;
  final DateTime postedAt;

  /// Beginn des Termins; `null` bei reinen Hinweisen.
  final DateTime? start;

  bool get isEvent => start != null;

  Announcement copyWith({
    String? categoryId,
    String? title,
    String? body,
    DateTime? start,
    bool clearStart = false,
  }) => Announcement(
    id: id,
    mosqueId: mosqueId,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    body: body ?? this.body,
    postedAt: postedAt,
    start: clearStart ? null : start ?? this.start,
  );

  /// Aus den Testdaten: Zeiten relativ zu [now] (`dayOffset`, `time`,
  /// `postedHoursAgo`), damit die Daten nie veralten.
  factory Announcement.fromTestJson(Map<String, dynamic> json, DateTime now) {
    DateTime? start;
    final offset = json['dayOffset'] as int?;
    if (offset != null) {
      final parts = (json['time'] as String? ?? '00:00').split(':');
      start = DateTime(
        now.year,
        now.month,
        now.day + offset,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
    return Announcement(
      id: json['id'] as String,
      mosqueId: json['mosqueId'] as String,
      categoryId: json['category'] as String? ?? 'info',
      title: json['title'] as String,
      body: json['body'] as String,
      postedAt: now.subtract(
        Duration(hours: json['postedHoursAgo'] as int? ?? 0),
      ),
      start: start,
    );
  }
}
