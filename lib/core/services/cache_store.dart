import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:moschee_app/core/logging/app_log.dart';

/// Kleiner Zwischenspeicher mit Ablaufzeit, im Speicher und optional
/// dauerhaft (SharedPreferences). Gedacht für Daten, die teuer zu laden
/// sind (Netz, Berechnungen): sofort den letzten Stand zeigen, im
/// Hintergrund aktualisieren ("stale-while-revalidate").
///
/// ```dart
/// final profiles = CacheStore<Profile>('profiles',
///     toJson: (p) => p.toJson(), fromJson: Profile.fromJson);
/// await profiles.restore();
/// final p = await profiles.get(id, () => api.loadProfile(id));
/// ```
class CacheStore<T> {
  CacheStore(
    this.name, {
    required this.toJson,
    required this.fromJson,
    this.maxAge = const Duration(hours: 12),
    this.persist = true,
  });

  final String name;
  final Map<String, dynamic> Function(T value) toJson;
  final T Function(Map<String, dynamic> json) fromJson;
  final Duration maxAge;
  final bool persist;

  final Map<String, ({T value, DateTime at})> _entries = {};
  final Map<String, Future<T>> _loading = {};
  bool _saveScheduled = false;

  String get _key => 'cache_$name';

  /// Letzter Stand ohne Laden (auch wenn abgelaufen).
  T? peek(String id) => _entries[id]?.value;

  /// Frischer Wert aus dem Cache, sonst [load]. Gleichzeitige Anfragen für
  /// dieselbe ID laden nur einmal.
  Future<T> get(String id, Future<T> Function() load, {bool force = false}) {
    final entry = _entries[id];
    if (!force &&
        entry != null &&
        DateTime.now().difference(entry.at) < maxAge) {
      return Future.value(entry.value);
    }
    return _loading[id] ??= load()
        .then((value) {
          put(id, value);
          return value;
        })
        .whenComplete(() => _loading.remove(id));
  }

  void put(String id, T value) {
    _entries[id] = (value: value, at: DateTime.now());
    _scheduleSave();
  }

  void remove(String id) {
    _entries.remove(id);
    _scheduleSave();
  }

  Future<void> restore() async {
    if (!persist) return;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      for (final MapEntry(:key, :value) in map.entries) {
        _entries[key] = (
          value: fromJson(Map<String, dynamic>.from(value['v'])),
          at: DateTime.fromMillisecondsSinceEpoch(value['t'] as int),
        );
      }
    } catch (e) {
      AppLog.warn('CacheStore($name) konnte nicht gelesen werden', e);
    }
  }

  Future<void> clear() async {
    _entries.clear();
    if (persist) await (await SharedPreferences.getInstance()).remove(_key);
  }

  /// Mehrere Änderungen in einem Schreibvorgang sichern.
  void _scheduleSave() {
    if (!persist || _saveScheduled) return;
    _saveScheduled = true;
    scheduleMicrotask(() async {
      _saveScheduled = false;
      final data = {
        for (final MapEntry(:key, :value) in _entries.entries)
          key: {'v': toJson(value.value), 't': value.at.millisecondsSinceEpoch},
      };
      await (await SharedPreferences.getInstance()).setString(
        _key,
        json.encode(data),
      );
    });
  }
}
