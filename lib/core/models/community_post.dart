/// Biete oder Suche.
enum PostKind { offer, request }

/// Kategorien der Hilfebörse.
enum PostCategory {
  education,
  children,
  moving,
  transport,
  repair,
  accompany,
  giveaway,
  other,
}

/// Beitrag in der Community (Hilfebörse): nur Text, Kontakt erst nach
/// „Interesse melden“ und Zustimmung beider Seiten.
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.body,
    required this.authorName,
    required this.mosqueId,
    required this.postedAt,
    this.interestCount = 0,
    this.myInterest = false,
    this.mine = false,
  });

  final String id;
  final PostKind kind;
  final PostCategory category;
  final String title;
  final String body;

  /// Nur Vorname (Datensparsamkeit).
  final String authorName;

  /// Moschee, über die der Beitrag läuft (für Ort und Umkreis).
  final String mosqueId;
  final DateTime postedAt;
  final int interestCount;
  final bool myInterest;
  final bool mine;

  CommunityPost copyWith({int? interestCount, bool? myInterest}) =>
      CommunityPost(
        id: id,
        kind: kind,
        category: category,
        title: title,
        body: body,
        authorName: authorName,
        mosqueId: mosqueId,
        postedAt: postedAt,
        interestCount: interestCount ?? this.interestCount,
        myInterest: myInterest ?? this.myInterest,
        mine: mine,
      );

  factory CommunityPost.fromTestJson(Map<String, dynamic> json, DateTime now) =>
      CommunityPost(
        id: json['id'] as String,
        kind: PostKind.values.asNameMap()[json['kind']] ?? PostKind.offer,
        category:
            PostCategory.values.asNameMap()[json['category']] ??
            PostCategory.other,
        title: json['title'] as String,
        body: json['body'] as String,
        authorName: json['author'] as String,
        mosqueId: json['mosqueId'] as String,
        postedAt: now.subtract(
          Duration(hours: json['postedHoursAgo'] as int? ?? 0),
        ),
        interestCount: json['interest'] as int? ?? 0,
      );
}
