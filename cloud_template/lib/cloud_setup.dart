// Nach lib/cloud/ kopieren. Siehe README.md im cloud_template.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/logging/app_log.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/firebase_options.dart'; // flutterfire configure
import 'package:moschee_app/cloud/firestore_item_repository.dart';

/// Einmal in `main()` vor `runApp` aufrufen: `await CloudSetup.init();`
abstract final class CloudSetup {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Absturzberichte nur aus Release-Builds.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    AppLog.reporter = _CrashlyticsReporter();

    // App Check schützt Firestore/Storage vor fremden Clients.
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
    // Token vor dem ersten Firestore-Zugriff holen (sonst Rennen beim Start).
    try {
      await FirebaseAppCheck.instance.getToken(true);
    } catch (e) {
      AppLog.warn('App Check token request failed', e);
    }

    // Offline-Cache: sofortiger Start, Änderungen werden nachgereicht.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    SettingsService.cloudAvailable = true;
    DataRepository.cloudSource = FirestoreItemRepository.forCurrentUser;
  }
}

class _CrashlyticsReporter implements AppLogReporter {
  @override
  void log(String message) => FirebaseCrashlytics.instance.log(message);

  @override
  void recordError(Object error, StackTrace? stack, String reason) =>
      FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
}
