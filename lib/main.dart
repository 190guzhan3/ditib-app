import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moschee_app/app.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/services/image_store.dart';
import 'package:moschee_app/core/services/location_service.dart';
import 'package:moschee_app/core/services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cloud einbauen: hier `await CloudSetup.init();` (siehe cloud_template).
  await SettingsService.instance.init();
  await AccountService.instance.init();
  // Ohne Wartezeit: Position kommt nach, Screens hören darauf.
  unawaited(LocationService.instance.init());
  await ImageStore.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());
}
