// Authentifizierungs-Service (Vorlage)
// ------------------------------------------------------------
// Bietet zentrale Methoden für Firebase Authentication:
//   • Registrieren / Anmelden / Abmelden (E-Mail, Google, Apple)
//   • Passwort zurücksetzen / Anzeigename ändern
//   • Account sicher löschen (inkl. Re-Authentifizierung)
//   • Benutzer wird automatisch in Firestore synchronisiert
//

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moschee_app/core/logging/app_log.dart';

/// Globaler Zugriff auf den AuthService.
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

/// Läuft vor Abmelden und Konto-Löschen, solange der Nutzer noch angemeldet
/// ist – z. B. Push-Token dieses Geräts entfernen:
/// `beforeSignOut.add(NotificationService.instance.unregisterCurrentUser);`
/// (in `CloudSetup.init`, sobald Push eingebaut ist).
final List<Future<void> Function()> beforeSignOut = [];

Future<void> _runBeforeSignOut() async {
  for (final hook in beforeSignOut) {
    try {
      await hook();
    } catch (e) {
      AppLog.warn('beforeSignOut fehlgeschlagen', e);
    }
  }
}

class AuthService {
  // Erst beim ersten Zugriff: So lässt sich der Dienst in Tests ohne
  // Firebase ersetzen (siehe test/support/fake_auth.dart).
  late final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Wie [authStateChanges], meldet aber auch geänderte Profildaten
  /// (Anzeigename, Bild, E-Mail-Bestätigung).
  Stream<User?> get userChanges => firebaseAuth.userChanges();

  static const _googleServerClientId =
      // Web-Client-ID aus GoogleService-Info.plist bzw. der Firebase-Konsole.
      'DEINE-WEB-CLIENT-ID.apps.googleusercontent.com';

  GoogleSignIn _buildGoogleSignIn() => GoogleSignIn(
    serverClientId: _googleServerClientId,
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  String _fallbackDisplayNameFor(User user) {
    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Benutzer';
  }

  String? get resolvedDisplayNameOrNull {
    final user = currentUser;
    if (user == null) return null;

    final currentDisplayName = user.displayName?.trim();
    if (currentDisplayName != null && currentDisplayName.isNotEmpty) {
      return currentDisplayName;
    }
    return _fallbackDisplayNameFor(user);
  }

  // ------------------------------------------------------------
  // 🔐 Authentifizierung
  // ------------------------------------------------------------

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = _buildGoogleSignIn();

      // Kein Zeitlimit: Beim ersten Mal fügt der Nutzer evtl. erst ein Konto
      // hinzu (inkl. Geräte-Backup usw.), das dauert gern länger als eine
      // Minute. Abbrechen kann er selbst.
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        AppLog.info('Google Sign-In vom Nutzer abgebrochen.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
          message:
              'Google ID Token fehlt. SHA-1 (Android) oder URL-Scheme (iOS) prüfen.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) await _upsertUserDoc(user, provider: 'google');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLog.warn('Firebase Auth Fehler [${e.code}]', e);
      rethrow;
    } catch (e) {
      AppLog.warn('Allgemeiner Fehler bei Google Sign-In', e);
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.toString(),
      );
    }
  }

  /// Sign in with Apple über Firebase (iOS/macOS nativ). Apple liefert den
  /// Namen nur beim ersten Mal; fehlt er, gilt der Teil vor dem @ der E-Mail,
  /// der sich in den Konto-Einstellungen ändern lässt.
  Future<UserCredential?> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final userCredential = await firebaseAuth.signInWithProvider(provider);
    final user = userCredential.user;
    if (user != null) {
      await _upsertUserDoc(user, provider: 'apple');
      await ensureCurrentUserDisplayNameFallback();
    }
    return userCredential;
  }

  /// Nutzerprofil nach einer Anmeldung über Google oder Apple anlegen bzw.
  /// aktualisieren.
  Future<void> _upsertUserDoc(User user, {required String provider}) async {
    final userDocRef = firestore.collection('users').doc(user.uid);
    await userDocRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
      'provider': provider,
    }, SetOptions(merge: true));
  }

  /// Benutzer mit E-Mail + Passwort anmelden
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Neues Benutzerkonto erstellen + Firestore-Eintrag
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user != null) {
      final resolvedDisplayName =
          (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : email.trim().split('@').first;

      await user.updateDisplayName(resolvedDisplayName);

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': resolvedDisplayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLog.info('Benutzer in Firestore erstellt: ${user.uid}');
      // Bestätigte Adressen sind für "Passwort vergessen" wichtig und
      // schützen das Konto. Die App bleibt auch unbestätigt nutzbar.
      try {
        await user.sendEmailVerification();
      } catch (e) {
        AppLog.warn('Bestätigungs-E-Mail nicht gesendet', e);
      }
    }
    return credential;
  }

  /// E-Mail-Adresse noch nicht bestätigt (nur bei E-Mail + Passwort).
  bool get needsEmailVerification =>
      isPasswordUser && currentUser?.emailVerified == false;

  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  /// Aktualisiert den Bestätigungsstatus nach dem Klick in der E-Mail.
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  /// Fragt beim Server nach, ob das Konto noch besteht. Ein in der
  /// Firebase-Konsole gelöschtes oder gesperrtes Konto bliebe sonst bis zum
  /// Ablauf des Tokens (bis zu einer Stunde) angemeldet. Ohne Netz oder bei
  /// anderen Fehlern gilt das Konto weiter als gültig.
  Future<bool> isAccountGone() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await user.reload();
      return false;
    } on FirebaseAuthException catch (e) {
      const goneCodes = {
        'user-not-found',
        'user-disabled',
        'user-token-expired',
        'invalid-user-token',
      };
      return goneCodes.contains(e.code);
    } catch (_) {
      return false;
    }
  }

  /// Abmelden
  Future<void> signOut() async {
    // Solange noch angemeldet: z. B. Push-Token dieses Geräts entfernen.
    await _runBeforeSignOut();
    final googleSignIn = _buildGoogleSignIn();

    try {
      await googleSignIn.signOut().timeout(const Duration(seconds: 8));
    } catch (_) {}

    await firebaseAuth.signOut().timeout(const Duration(seconds: 10));
  }

  // ------------------------------------------------------------
  // 👤 Benutzerverwaltung & Account-Aktionen
  // ------------------------------------------------------------

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateUsername({required String username}) async {
    if (currentUser == null) return;
    await currentUser!.updateDisplayName(username);

    // 💡 OPTIMIERT: Nutzt merge: true, um Fehler zu vermeiden, falls das Doc leer sein sollte
    await firestore.collection('users').doc(currentUser!.uid).set({
      'displayName': username,
    }, SetOptions(merge: true));
  }

  Future<String?> ensureCurrentUserDisplayNameFallback() async {
    final user = currentUser;
    if (user == null) return null;

    final currentDisplayName = user.displayName?.trim();
    final resolvedName =
        (currentDisplayName != null && currentDisplayName.isNotEmpty)
        ? currentDisplayName
        : _fallbackDisplayNameFor(user);

    if (currentDisplayName == null || currentDisplayName.isEmpty) {
      await user.updateDisplayName(resolvedName);
    }

    await firestore.collection('users').doc(user.uid).set({
      'displayName': resolvedName,
      'email': user.email,
    }, SetOptions(merge: true));

    return resolvedName;
  }

  /// Passwörter werden überall gleich (ohne Leerzeichen am Rand) behandelt,
  /// wie bei Registrierung und Anmeldung.
  Future<void> updatePassword({required String newPassword}) async {
    if (currentUser == null) return;
    await currentUser!.updatePassword(newPassword.trim());
  }

  Future<void> requestEmailChange({
    required String newEmail,
    String? password,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await reauthenticateForSensitiveAction(password: password);
    await user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  // ------------------------------------------------------------
  // 🛡️ Sicherheit & Löschung (Re-Authentifizierung)
  // ------------------------------------------------------------

  bool get isPasswordUser =>
      currentUser?.providerData.any(
        (entry) => entry.providerId == 'password',
      ) ==
      true;
  bool get isGoogleUser =>
      currentUser?.providerData.any(
        (entry) => entry.providerId == 'google.com',
      ) ==
      true;
  bool get isAppleUser =>
      currentUser?.providerData.any(
        (entry) => entry.providerId == 'apple.com',
      ) ==
      true;

  /// Autorisierungscode der letzten Apple-Bestätigung; damit widerruft die
  /// App beim Löschen des Kontos den Zugriff bei Apple (App-Store-Vorgabe).
  String? _appleAuthorizationCode;

  Future<void> reauthenticateForSensitiveAction({String? password}) async {
    final user = currentUser;
    if (user == null) return;

    if (isPasswordUser) {
      final email = user.email;
      if (email == null || password == null || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-password-for-reauth',
          message: 'Passwort für die Bestätigung fehlt.',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (isGoogleUser) {
      final googleSignIn = _buildGoogleSignIn();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'reauth-cancelled',
          message: 'Bestätigung mit Google wurde abgebrochen.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (isAppleUser) {
      final result = await user.reauthenticateWithProvider(AppleAuthProvider());
      _appleAuthorizationCode = result.additionalUserInfo?.authorizationCode;
    }
  }

  Future<void> deleteCurrentAccount({String? password}) async {
    await reauthenticateForSensitiveAction(password: password);
    await finalizeCurrentAccountDeletion();
  }

  Future<void> finalizeCurrentAccountDeletion() async {
    final user = currentUser;
    if (user == null) return;

    await _runBeforeSignOut();
    await firestore.collection('users').doc(user.uid).delete();
    final appleCode = _appleAuthorizationCode;
    if (isAppleUser && appleCode != null) {
      try {
        await firebaseAuth.revokeTokenWithAuthorizationCode(appleCode);
      } catch (e) {
        AppLog.warn('Apple-Zugriff konnte nicht widerrufen werden', e);
      }
      _appleAuthorizationCode = null;
    }
    await user.delete();
    await firebaseAuth.signOut();
  }

  // ------------------------------------------------------------
  // ℹ️ Hilfsfunktionen
  // ------------------------------------------------------------
  bool get isSignedIn => currentUser != null;
  String get displayName =>
      resolvedDisplayNameOrNull ?? currentUser?.email ?? 'Unbekannt';
  String? get email => currentUser?.email;
  String? get uid => currentUser?.uid;
}
