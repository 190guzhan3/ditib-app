import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moschee_app/core/services/prayer_times.dart';
import 'package:moschee_app/core/theme/theme.dart';

/// Woher die Moschee- und Community-Daten kommen.
///
/// - [testData]: Testdaten aus `assets/testdata/` (Standard, solange es
///   keine Cloud gibt). Änderungen gelten nur bis zum Neustart.
/// - [cloud]: nur mit eingebauter Cloud (siehe cloud_template/README.md).
enum AppMode { testData, cloud }

/// Geräteeinstellungen: Darstellung, Sprache, Datenquelle und die eigene
/// Auswahl (Moscheen, Umkreis, Gebetszeiten-Methode). Bleibt auf dem Gerät.
class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _themeModeKey = 'theme_mode';
  static const _accentKey = 'accent_color';
  static const _localeKey = 'locale';
  static const _modeKey = 'app_mode';
  static const _myMosquesKey = 'my_mosques';
  static const _radiusKey = 'radius_km';
  static const _prayerMethodKey = 'prayer_method';
  static const _introKey = 'intro_seen';
  static const _adminPreviewKey = 'admin_preview';

  /// Sprachen der App; die erste ist der Ersatz für nicht unterstützte
  /// Systemsprachen.
  static const languages = ['de', 'tr', 'en'];

  /// Ob die Cloud-Anbindung eingebaut ist. Wird beim Einbau der Cloud
  /// (cloud_template) auf `true` gesetzt.
  static bool cloudAvailable = false;

  static const radiusChoices = [5, 10, 20, 30, 50, 100];

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  Color _accent = AppColors.defaultAccent;
  Locale? _locale;
  AppMode _mode = AppMode.testData;
  List<String>? _myMosqueIds;
  int _radiusKm = 20;
  PrayerMethod _prayerMethod = PrayerMethod.diyanet;
  bool _introSeen = false;
  bool _adminPreview = false;

  ThemeMode get themeMode => _themeMode;
  Color get accent => _accent;

  /// `null` = Systemsprache.
  Locale? get locale => _locale;
  AppMode get mode => _mode;

  /// Eigene Moscheen in gewählter Reihenfolge (die erste ist die
  /// Hauptmoschee). `null` = noch nie gewählt.
  List<String>? get myMosqueIds => _myMosqueIds;
  int get radiusKm => _radiusKm;
  PrayerMethod get prayerMethod => _prayerMethod;
  bool get introSeen => _introSeen;

  /// Vorübergehend: Verwaltung für die Hauptmoschee ansehen, ohne echte
  /// Rolle. Fällt weg, sobald Rollen aus der Cloud kommen.
  bool get adminPreview => _adminPreview;

  /// Sprache, die die App gerade zeigt: gewählt oder System (wenn
  /// unterstützt), sonst Deutsch.
  String get effectiveLanguage {
    final code =
        _locale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return languages.contains(code) ? code : languages.first;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode =
        ThemeMode.values.asNameMap()[_prefs.getString(_themeModeKey)] ??
        ThemeMode.system;
    final accent = _prefs.getInt(_accentKey);
    _accent = accent != null ? Color(accent) : AppColors.defaultAccent;
    final locale = _prefs.getString(_localeKey);
    _locale = locale == null ? null : Locale(locale);
    _mode =
        AppMode.values.asNameMap()[_prefs.getString(_modeKey)] ??
        AppMode.testData;
    if (_mode == AppMode.cloud && !cloudAvailable) _mode = AppMode.testData;
    _myMosqueIds = _prefs.getStringList(_myMosquesKey);
    _radiusKm = _prefs.getInt(_radiusKey) ?? 20;
    _prayerMethod =
        PrayerMethod.values.asNameMap()[_prefs.getString(_prayerMethodKey)] ??
        PrayerMethod.diyanet;
    _introSeen = _prefs.getBool(_introKey) ?? false;
    _adminPreview = _prefs.getBool(_adminPreviewKey) ?? false;
  }

  Future<void> setAdminPreview(bool value) async {
    _adminPreview = value;
    notifyListeners();
    await _prefs.setBool(_adminPreviewKey, value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();
    await _prefs.setString(_themeModeKey, value.name);
  }

  Future<void> setAccent(Color value) async {
    _accent = value;
    notifyListeners();
    await _prefs.setInt(_accentKey, value.toARGB32());
  }

  Future<void> setLocale(Locale? value) async {
    _locale = value;
    notifyListeners();
    if (value == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, value.languageCode);
    }
  }

  Future<void> setMode(AppMode value) async {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
    await _prefs.setString(_modeKey, value.name);
  }

  Future<void> setMyMosques(List<String> ids) async {
    _myMosqueIds = List.unmodifiable(ids);
    notifyListeners();
    await _prefs.setStringList(_myMosquesKey, ids);
  }

  Future<void> setRadiusKm(int value) async {
    _radiusKm = value;
    notifyListeners();
    await _prefs.setInt(_radiusKey, value);
  }

  Future<void> setPrayerMethod(PrayerMethod value) async {
    _prayerMethod = value;
    notifyListeners();
    await _prefs.setString(_prayerMethodKey, value.name);
  }

  Future<void> setIntroSeen(bool value) async {
    _introSeen = value;
    notifyListeners();
    await _prefs.setBool(_introKey, value);
  }

  /// Setzt Darstellung und Auswahl zurück; Einführung und Konto bleiben.
  Future<void> reset() async {
    for (final key in [
      _themeModeKey,
      _accentKey,
      _localeKey,
      _modeKey,
      _myMosquesKey,
      _radiusKey,
      _prayerMethodKey,
      _adminPreviewKey,
    ]) {
      await _prefs.remove(key);
    }
    await init();
    notifyListeners();
  }
}
