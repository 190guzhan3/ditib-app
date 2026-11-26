import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';

class NetworkGuardService {
  NetworkGuardService._();

  /// Ersetzt in Tests die echte Verbindungsprüfung (DNS-Lookup).
  @visibleForTesting
  static Future<bool> Function()? connectivityCheckOverride;

  static Future<bool> hasInternetConnection() async {
    final override = connectivityCheckOverride;
    if (override != null) return override();
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> ensureOnlineOrNotify(BuildContext context) async {
    final isOnline = await hasInternetConnection();
    if (isOnline) return true;
    if (!context.mounted) return false;

    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.common_internet_required)));
    return false;
  }
}
