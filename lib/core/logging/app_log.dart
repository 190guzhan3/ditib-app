import 'package:flutter/foundation.dart';

/// Einheitliches Logging.
///
/// In Debug-Builds landet alles in der Konsole. In Release-Builds wird
/// nichts ausgegeben. Mit Cloud lassen sich Warnungen und
/// Fehler an Crashlytics weiterleiten: [reporter] setzen (siehe cloud_template).
abstract final class AppLog {
  /// Ablauf-Hinweise, nur beim Entwickeln interessant.
  static void info(String message) {
    if (kDebugMode) debugPrint(message);
  }

  /// Abgefangener, erwartbarer Fehler (Netz, fehlende Rechte, Cache).
  /// In Release ein kurzer Eintrag, der bei späteren Abstürzen mitkommt.
  static void warn(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint(error == null ? message : '$message: $error');
      return;
    }
    reporter?.log(error == null ? message : '$message (${error.runtimeType})');
  }

  /// Unerwarteter Fehler: In Release ein nicht-fataler Bericht an [reporter].
  static void error(String message, Object error, [StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('$message: $error');
      if (stack != null) debugPrintStack(stackTrace: stack);
      return;
    }
    reporter?.recordError(error, stack, message);
  }

  /// Optionaler Fehlerdienst für Release-Builds (z. B. Crashlytics).
  static AppLogReporter? reporter;
}

/// Ziel für Meldungen in Release-Builds.
abstract interface class AppLogReporter {
  void log(String message);
  void recordError(Object error, StackTrace? stack, String reason);
}
