import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ergebnis beim Einschalten des Standorts.
enum LocationResult { ok, denied, deniedForever, serviceOff, unavailable }

/// Standort des Handys – nur auf Wunsch, nur ungefähr, nur im Speicher.
///
/// Wird für Qibla, die eigene Position auf der Karte und den Umkreis
/// genutzt. Ohne Standort zählt die Hauptmoschee. Die Position wird nie
/// gespeichert oder gesendet; gemerkt wird nur, ob der Nutzer es will.
class LocationService extends ChangeNotifier {
  LocationService._();
  static final LocationService instance = LocationService._();

  static const _key = 'use_location';

  bool _enabled = false;
  ({double lat, double lng})? _position;

  /// Der Nutzer möchte den Standort verwenden.
  bool get enabled => _enabled;

  /// Letzte Position; `null`, solange keine da ist.
  ({double lat, double lng})? get position => _enabled ? _position : null;

  /// Lädt die Einstellung und holt, falls gewünscht und erlaubt, die
  /// Position (ohne nachzufragen).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? false;
    if (_enabled) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await refresh();
      }
    }
  }

  /// Fragt bei Bedarf nach der Erlaubnis und holt die Position.
  Future<LocationResult> enable() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationResult.serviceOff;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationResult.deniedForever;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return LocationResult.denied;
    }
    _enabled = true;
    await (await SharedPreferences.getInstance()).setBool(_key, true);
    return await refresh() ? LocationResult.ok : LocationResult.unavailable;
  }

  Future<void> disable() async {
    _enabled = false;
    _position = null;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool(_key, false);
  }

  /// Neue Position holen (ungefähr genügt). Liefert `true` bei Erfolg.
  Future<bool> refresh() async {
    try {
      final p =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 15),
            ),
          );
      _position = (lat: p.latitude, lng: p.longitude);
      notifyListeners();
      return true;
    } catch (_) {
      notifyListeners();
      return false;
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
