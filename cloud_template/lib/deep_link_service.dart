// Nach lib/cloud/ kopieren. Braucht app_links (pubspec_additions) und für
// https-Links die Einrichtung von App Links / Universal Links
// (native/ios_Runner.entitlements.example, AndroidManifest intent-filter).
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:moschee_app/core/logging/app_log.dart';
import 'package:moschee_app/cloud/groups/group_invite.dart';

/// Ein geöffneter Einladungslink. Weitere Linkarten (z. B. direkt zu einem
/// Eintrag) nach demselben Muster ergänzen.
class AppLink {
  const AppLink.invite(this.token);

  final String token;

  /// Nur vollständige Links; ein nackter Token kommt nie über das System.
  static AppLink? parse(String input) {
    final token = GroupInviteLinks.tokenFromLink(input);
    return token == null ? null : AppLink.invite(token);
  }
}

/// Was die App mit einem geöffneten Einladungslink tut.
enum InviteLinkAction {
  /// Beitrittsdialog zeigen (vorher mit `GroupAccess.checkInvite` prüfen).
  join,

  /// Erst anmelden; der Link wartet so lange in [DeepLinkService.pending].
  signInFirst,
}

InviteLinkAction decideInviteLinkAction({required bool isSignedIn}) =>
    isSignedIn ? InviteLinkAction.join : InviteLinkAction.signInFirst;

/// Nimmt Links entgegen, mit denen die App gestartet oder geöffnet wurde,
/// und hält den jeweils letzten bereit, bis die Oberfläche ihn verarbeitet.
///
/// Einmal nach dem Start aufrufen: `DeepLinkService.instance.start()`.
/// Die Oberfläche hört auf [pending] und holt den Link mit [take] ab.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final ValueNotifier<AppLink?> pending = ValueNotifier(null);
  StreamSubscription<Uri>? _subscription;

  Future<void> start() async {
    if (_subscription != null || kIsWeb) return;
    // uriLinkStream liefert auch den Link, mit dem die App gestartet wurde.
    _subscription = AppLinks().uriLinkStream.listen(
      (uri) => receive(uri.toString()),
      onError: (Object error) => AppLog.warn('⚠️ Deep Link', error),
    );
  }

  /// Auch für Links aus dem QR-Scanner oder der Zwischenablage.
  void receive(String link) {
    final parsed = AppLink.parse(link);
    if (parsed != null) pending.value = parsed;
  }

  /// Übernimmt den wartenden Link zur Verarbeitung.
  AppLink? take() {
    final link = pending.value;
    pending.value = null;
    return link;
  }
}
