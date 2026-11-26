// Nach lib/cloud/ kopieren. Braucht firebase_messaging (pubspec_additions).
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:moschee_app/core/logging/app_log.dart';

/// Push-Benachrichtigungen (Firebase Cloud Messaging).
///
/// Speichert das Geräte-Token unter `users/{uid}/fcmTokens/{token}`, damit die
/// Cloud Functions (`notifyUsers` in functions/index.js) Admins bzw.
/// Mitglieder benachrichtigen können. Beim Abmelden wird das Token wieder
/// entfernt, damit ein geteiltes Gerät keine Nachrichten des vorherigen
/// Kontos bekommt – dazu in `CloudSetup.init`:
/// `beforeSignOut.add(NotificationService.instance.unregisterCurrentUser);`
///
/// Nach dem Anmelden `registerCurrentUser()` aufrufen. Am besten erst, wenn
/// der Nutzer etwas tut, wofür Push sinnvoll ist (Erlaubnis-Dialog).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Bereich, den eine angetippte Benachrichtigung öffnen soll (Feld
  /// `screen` in den Daten der Nachricht); null, wenn nichts ansteht. Die
  /// Oberfläche hört darauf, wechselt dorthin und setzt es wieder auf null.
  final ValueNotifier<String?> openScreenRequested = ValueNotifier(null);

  StreamSubscription<String>? _tokenRefresh;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  String? _registeredUid;
  String? _registeredToken;

  bool get _isSupported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Fragt einmalig nach der Erlaubnis und registriert dieses Gerät für den
  /// angemeldeten Nutzer. Mehrfache Aufrufe sind unkritisch.
  Future<void> registerCurrentUser() async {
    if (!_isSupported) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _registeredUid == user.uid) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _listenForOpenedNotifications();
      final token = await messaging.getToken();
      if (token == null) return;
      await _saveToken(user.uid, token);
      _registeredUid = user.uid;

      await _tokenRefresh?.cancel();
      _tokenRefresh = messaging.onTokenRefresh.listen((next) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        final previous = _registeredToken;
        await _saveToken(uid, next);
        if (previous != null && previous != next) {
          await _tokenRef(uid, previous).delete().catchError((_) {});
        }
      });
    } catch (error) {
      AppLog.warn('⚠️ Push-Registrierung fehlgeschlagen', error);
    }
  }

  /// Entfernt dieses Gerät vom aktuellen Konto (vor dem Abmelden aufrufen).
  Future<void> unregisterCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? _registeredUid;
    final token = _registeredToken;
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    _registeredUid = null;
    _registeredToken = null;
    if (!_isSupported || uid == null || token == null) return;
    try {
      await _tokenRef(uid, token).delete();
    } catch (error) {
      AppLog.warn('⚠️ Push-Token konnte nicht entfernt werden', error);
    }
  }

  DocumentReference<Map<String, dynamic>> _tokenRef(String uid, String token) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token);

  Future<void> _saveToken(String uid, String token) async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    await _tokenRef(uid, token).set({
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      // Für Texte und Uhrzeiten in den Benachrichtigungen.
      'locale': locale.languageCode,
      'utcOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _registeredToken = token;
  }

  void _listenForOpenedNotifications() {
    if (_openedSubscription != null) return;
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _openFrom,
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _openFrom(message);
    });
  }

  void _openFrom(RemoteMessage message) {
    final screen = message.data['screen'];
    openScreenRequested.value = screen is String && screen.isNotEmpty
        ? screen
        : 'home';
  }
}
