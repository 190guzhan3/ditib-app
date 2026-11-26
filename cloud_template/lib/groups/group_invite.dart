// Nach lib/cloud/groups/ kopieren. Siehe cloud_template/README.md.
import 'dart:math';

/// Ein Einladungslink zu einer Gruppe (`groupInvites/{token}`).
///
/// Der Token ist zufällig und lang genug, um nicht erraten zu werden. Wer
/// den Link hat, tritt ohne weitere Freigabe bei, solange er gültig ist.
/// Einmal-Code (z. B. für einen neuen Verwalter): `maxUses: 1`.
/// Eingelöst wird nur über die Cloud Function `redeemGroupInvite`.
class GroupInvite {
  final String token;
  final String groupId;
  final String groupName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// Rolle, die man beim Einlösen bekommt (`member` oder `admin`).
  final String role;

  /// `null` bedeutet: beliebig oft nutzbar bis zum Ablauf.
  final int? maxUses;
  final int useCount;
  final bool revoked;

  const GroupInvite({
    required this.token,
    required this.groupId,
    required this.groupName,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    this.role = 'member',
    this.maxUses,
    this.useCount = 0,
    this.revoked = false,
  });

  bool get isSingleUse => maxUses == 1;

  bool get isUsedUp => maxUses != null && useCount >= maxUses!;

  bool isActiveAt(DateTime now) =>
      !revoked && !isUsedUp && expiresAt.isAfter(now);

  /// Liest Werte, die die Firestore-Schicht bereits in [DateTime]
  /// umgewandelt hat (oder ISO-Texte).
  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return GroupInvite(
      token: json['token'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      expiresAt: parseDate(json['expiresAt']),
      role: json['role'] as String? ?? 'member',
      maxUses: (json['maxUses'] as num?)?.toInt(),
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
      revoked: json['revoked'] as bool? ?? false,
    );
  }
}

/// Aufbau und Erkennung von Einladungslinks.
class GroupInviteLinks {
  const GroupInviteLinks._();

  /// Firebase-Hosting-Domain des Projekts (anpassen). Unter
  /// `/invite/<token>` liegt die Seite, die die App öffnet bzw. in den
  /// Store weiterleitet.
  static const String host = 'dein-projekt.web.app';
  static const String pathPrefix = '/invite/';

  /// Eigenes URL-Schema als Rückfall, solange keine App Links eingerichtet
  /// sind (anpassen, auch in AndroidManifest/Info.plist).
  static const String appScheme = 'moscheeapp';

  static const String _tokenChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const int tokenLength = 32;
  static final RegExp _tokenPattern = RegExp(r'^[A-Za-z0-9]{22,64}$');

  static String generateToken({Random? random}) {
    final source = random ?? Random.secure();
    return List.generate(
      tokenLength,
      (_) => _tokenChars[source.nextInt(_tokenChars.length)],
    ).join();
  }

  static Uri linkFor(String token) =>
      Uri(scheme: 'https', host: host, path: '$pathPrefix$token');

  /// Erkennt einen Token in einem Link, einem QR-Inhalt oder einem
  /// eingefügten Token.
  static String? tokenFrom(String input) {
    final trimmed = input.trim();
    if (_tokenPattern.hasMatch(trimmed)) return trimmed;
    return tokenFromLink(trimmed);
  }

  /// Nur vollständige Links (https://host/invite/… oder schema://invite/…).
  static String? tokenFromLink(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null || !uri.hasScheme) return null;
    final isAppScheme = uri.scheme == appScheme;
    // Uri schreibt den Host immer klein.
    if (!isAppScheme && uri.host != host.toLowerCase()) return null;
    // Bei schema://invite/<token> steht "invite" im Host-Teil.
    final segments = [
      if (isAppScheme) uri.host,
      ...uri.pathSegments,
    ].where((segment) => segment.isNotEmpty).toList();
    final index = segments.indexOf('invite');
    if (index < 0 || index + 1 >= segments.length) return null;
    final candidate = segments[index + 1];
    return _tokenPattern.hasMatch(candidate) ? candidate : null;
  }
}
