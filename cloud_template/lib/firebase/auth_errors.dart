import 'package:firebase_auth/firebase_auth.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';

/// Wobei der Fehler auftrat; bestimmt die allgemeine Meldung, wenn der
/// Fehlercode nichts Genaueres hergibt.
enum AuthAction {
  login,
  register,
  social,
  reauth,
  changePassword,
  changeEmail,
  delete,
}

/// Fehlercode einer Anmeldung, auch wenn er nur im Text steckt (z. B. bei
/// Plattform-Fehlern von Google oder Apple).
String authErrorCode(Object error) {
  if (error is FirebaseAuthException) return error.code;
  return error.toString();
}

/// Abbruch durch den Nutzer (Google-/Apple-Dialog geschlossen): keine
/// Fehlermeldung anzeigen.
bool isAuthCancellation(Object error) {
  final code = authErrorCode(error).toLowerCase();
  return code.contains('cancel') ||
      code.contains('web-context-canceled') ||
      code.contains('1001');
}

/// Verständliche Meldung zu einem Anmelde-Fehler. `null` bei Abbruch durch
/// den Nutzer.
String? authErrorMessage(
  AppLocalizations t,
  Object error, {
  required AuthAction action,
}) {
  if (isAuthCancellation(error)) return null;
  final code = authErrorCode(error);
  bool has(String value) => code.contains(value);

  if (has('network-request-failed') || has('network_error')) {
    return t.auth_error_network;
  }
  if (has('too-many-requests')) return t.auth_login_error_too_many_requests;
  if (has('user-disabled')) return t.auth_error_user_disabled;
  if (has('invalid-email')) return t.auth_email_invalid;
  if (has('email-already-in-use')) return t.auth_register_error_email_in_use;
  if (has('weak-password')) return t.auth_register_error_weak_password;
  if (has('account-exists-with-different-credential') ||
      has('credential-already-in-use')) {
    return t.auth_error_other_provider;
  }
  if (has('requires-recent-login')) return t.auth_error_recent_login;
  if (has('missing-password-for-reauth')) {
    return t.settings_account_current_password_invalid;
  }
  if (has('wrong-password') ||
      has('invalid-credential') ||
      has('INVALID_LOGIN_CREDENTIALS') ||
      has('user-not-found')) {
    return switch (action) {
      AuthAction.login => t.auth_error_wrong_credentials,
      AuthAction.social => t.auth_error_social,
      _ => t.settings_account_current_password_invalid,
    };
  }
  return switch (action) {
    AuthAction.login => t.auth_login_error_default,
    AuthAction.register => t.auth_register_error_default,
    AuthAction.social => t.auth_error_social,
    AuthAction.reauth => t.settings_account_current_password_invalid,
    AuthAction.changePassword => t.settings_account_password_change_error,
    AuthAction.changeEmail => t.settings_account_email_change_error,
    AuthAction.delete => t.settings_account_delete_error,
  };
}
