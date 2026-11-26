import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/location_service.dart';

/// Standort einschalten; bei Problemen ein Hinweis (mit Sprung in die
/// Systemeinstellungen, wenn dauerhaft abgelehnt). Liefert `true` bei
/// Erfolg.
Future<bool> enableLocation(BuildContext context) async {
  final t = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final location = LocationService.instance;
  final result = await location.enable();
  final message = switch (result) {
    LocationResult.ok => null,
    LocationResult.denied || LocationResult.deniedForever => t.location_denied,
    LocationResult.serviceOff => t.location_service_off,
    LocationResult.unavailable => t.location_unavailable,
  };
  if (message != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action:
              result == LocationResult.deniedForever ||
                  result == LocationResult.serviceOff
              ? SnackBarAction(
                  label: t.location_open_settings,
                  onPressed: location.openSettings,
                )
              : null,
        ),
      );
  }
  return result == LocationResult.ok;
}
