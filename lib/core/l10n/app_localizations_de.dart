// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get app_title => 'Cemaat';

  @override
  String get nav_home => 'Start';

  @override
  String get nav_mosques => 'Moscheen';

  @override
  String get nav_community => 'Community';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_delete => 'Löschen';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_continue => 'Weiter';

  @override
  String get common_skip => 'Überspringen';

  @override
  String get common_show_all => 'Alle anzeigen';

  @override
  String get common_loading_please_wait => 'Einen Moment bitte …';

  @override
  String get common_internet_required =>
      'Dafür wird eine Internetverbindung benötigt.';

  @override
  String get common_irreversible => 'Das kann nicht rückgängig gemacht werden.';

  @override
  String get image_change => 'Bild ändern';

  @override
  String get image_choose => 'Bild wählen';

  @override
  String get image_view => 'Bild ansehen';

  @override
  String get image_remove => 'Bild entfernen';

  @override
  String get tooltip_qibla => 'Qibla-Kompass';

  @override
  String get tooltip_settings => 'Einstellungen';

  @override
  String get date_today => 'Heute';

  @override
  String get date_tomorrow => 'Morgen';

  @override
  String get ago_now => 'gerade eben';

  @override
  String ago_minutes(int n) {
    return 'vor $n Min.';
  }

  @override
  String ago_hours(int n) {
    return 'vor $n Std.';
  }

  @override
  String ago_days(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'vor $n Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String duration_hm(int h, int m) {
    return '$h Std. $m Min.';
  }

  @override
  String duration_m(int m) {
    return '$m Min.';
  }

  @override
  String distance_km(String km) {
    return '$km km';
  }

  @override
  String get home_my_mosques => 'Meine Moscheen';

  @override
  String get home_add_mosque => 'Hinzufügen';

  @override
  String get home_no_mosque_title => 'Wähle deine Moschee';

  @override
  String get home_no_mosque_message =>
      'Dann siehst du hier ihre Termine, Ankündigungen und Gebetszeiten.';

  @override
  String get home_choose_mosque => 'Moschee wählen';

  @override
  String get home_events => 'Termine';

  @override
  String get home_events_empty => 'Keine anstehenden Termine.';

  @override
  String get home_notices => 'Ankündigungen';

  @override
  String get home_nearby => 'In der Umgebung';

  @override
  String home_nearby_count(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Moscheen',
      one: '1 Moschee',
      zero: 'Keine weiteren Moscheen',
    );
    return '$_temp0 im Umkreis von $km km';
  }

  @override
  String get home_nearby_empty =>
      'Im Umkreis stehen keine Termine an. Vergrößere den Umkreis, um mehr zu sehen.';

  @override
  String get radius_title => 'Umkreis';

  @override
  String radius_hint(String name) {
    return 'Gemessen ab deiner Hauptmoschee ($name).';
  }

  @override
  String get prayer_title => 'Gebetszeiten';

  @override
  String get prayer_fajr => 'Fadschr';

  @override
  String get prayer_sunrise => 'Sonne';

  @override
  String get prayer_dhuhr => 'Dhuhr';

  @override
  String get prayer_asr => 'Asr';

  @override
  String get prayer_maghrib => 'Maghrib';

  @override
  String get prayer_isha => 'Ischa';

  @override
  String prayer_next_in(String prayer, String duration) {
    return '$prayer in $duration';
  }

  @override
  String prayer_for(String city, String method) {
    return '$city · $method';
  }

  @override
  String prayer_friday(String time) {
    return 'Freitagsgebet $time';
  }

  @override
  String get prayer_method_diyanet => 'Diyanet';

  @override
  String get prayer_method_muslimWorldLeague => 'Muslim World League';

  @override
  String get prayer_method_northAmerica => 'ISNA (Nordamerika)';

  @override
  String get kind_info => 'Hinweis';

  @override
  String get kind_event => 'Veranstaltung';

  @override
  String get kind_cenaze => 'Cenaze';

  @override
  String get kind_course => 'Kurs';

  @override
  String get kind_festival => 'Fest';

  @override
  String get kind_youth => 'Jugend';

  @override
  String get announcement_open_mosque => 'Zur Moschee';

  @override
  String get mosques_search_hint => 'Moschee oder Ort';

  @override
  String get mosques_view_map => 'Karte';

  @override
  String get mosques_view_list => 'Liste';

  @override
  String get mosques_all_regions => 'Alle Regionen';

  @override
  String mosques_only_radius(int km) {
    return 'Umkreis $km km';
  }

  @override
  String get mosques_empty => 'Keine Moschee gefunden.';

  @override
  String mosques_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Moscheen',
      one: '1 Moschee',
    );
    return '$_temp0';
  }

  @override
  String region_label(int number) {
    return 'Region $number';
  }

  @override
  String get map_attribution => '© OpenStreetMap-Mitwirkende';

  @override
  String get mosque_mine => 'Meine Moschee';

  @override
  String get mosque_primary => 'Hauptmoschee';

  @override
  String get mosque_add_mine => 'Als meine Moschee';

  @override
  String get mosque_remove_mine => 'Entfernen';

  @override
  String get mosque_make_primary => 'Als Hauptmoschee';

  @override
  String get mosque_verified => 'Verifiziert';

  @override
  String get mosque_about => 'Über die Moschee';

  @override
  String get mosque_prayer_today => 'Gebetszeiten heute';

  @override
  String get mosque_no_events => 'Derzeit keine Termine.';

  @override
  String get mosque_picker_title => 'Moschee wählen';

  @override
  String get association_ditib => 'DITIB';

  @override
  String get association_igmg => 'IGMG';

  @override
  String get association_vikz => 'VIKZ';

  @override
  String get association_zmd => 'ZMD';

  @override
  String get association_independent => 'Unabhängig';

  @override
  String get community_all => 'Alle';

  @override
  String get community_offers => 'Biete';

  @override
  String get community_requests => 'Suche';

  @override
  String get community_sort_newest => 'Neueste zuerst';

  @override
  String get community_sort_nearby => 'In der Nähe zuerst';

  @override
  String get community_all_categories => 'Alle Kategorien';

  @override
  String get community_hint =>
      'Nur Text, kein Chat: Kontaktdaten werden erst geteilt, wenn beide zustimmen.';

  @override
  String get community_empty => 'Keine Beiträge für diese Auswahl.';

  @override
  String get category_education => 'Lernen & Nachhilfe';

  @override
  String get category_children => 'Kinderbetreuung';

  @override
  String get category_moving => 'Umzug & Tragen';

  @override
  String get category_transport => 'Fahrten';

  @override
  String get category_repair => 'Handwerk & Technik';

  @override
  String get category_accompany => 'Begleitung & Alltag';

  @override
  String get category_giveaway => 'Zu verschenken';

  @override
  String get category_other => 'Sonstiges';

  @override
  String get post_offer => 'Biete';

  @override
  String get post_request => 'Suche';

  @override
  String get post_mine => 'Dein Beitrag';

  @override
  String get post_interest => 'Interesse melden';

  @override
  String get post_interest_done => 'Interesse gemeldet';

  @override
  String post_interest_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen interessiert',
      one: '1 Person interessiert',
      zero: 'Noch niemand interessiert',
    );
    return '$_temp0';
  }

  @override
  String post_interest_sent(String name) {
    return 'Interesse gemeldet. Sobald $name zustimmt, seht ihr gegenseitig eure Kontaktdaten.';
  }

  @override
  String get post_report => 'Beitrag melden';

  @override
  String get post_reported => 'Danke, der Beitrag wird geprüft.';

  @override
  String get post_new => 'Beitrag';

  @override
  String get post_new_title => 'Neuer Beitrag';

  @override
  String get post_form_title => 'Titel';

  @override
  String get post_form_body => 'Beschreibung';

  @override
  String get post_form_category => 'Kategorie';

  @override
  String get post_form_mosque => 'Gemeinde';

  @override
  String get post_form_rules =>
      'Bitte keine Telefonnummern, Adressen oder gewerblichen Angebote. Beiträge können gemeldet werden.';

  @override
  String get post_form_publish => 'Veröffentlichen';

  @override
  String get post_form_required => 'Bitte ausfüllen.';

  @override
  String get post_created => 'Beitrag veröffentlicht.';

  @override
  String get account_needed_title => 'Dafür brauchst du ein Konto';

  @override
  String get account_needed_message =>
      'Lesen geht ohne Konto. Um Beiträge zu erstellen oder Interesse zu melden, brauchst du ein Konto. So bleibt die Community sicher.';

  @override
  String get qibla_title => 'Qibla';

  @override
  String qibla_degrees(int degrees) {
    return '$degrees° von Norden';
  }

  @override
  String qibla_based_on(String place) {
    return 'Berechnet für $place';
  }

  @override
  String get qibla_no_sensor =>
      'Kein Kompass verfügbar. Richte das Handy nach Norden aus, dann zeigt der Pfeil Richtung Mekka.';

  @override
  String get qibla_calibrate =>
      'Für genaue Werte das Handy flach halten und einmal in einer Acht bewegen.';

  @override
  String get qibla_aligned => 'Richtung stimmt';

  @override
  String get qibla_turn => 'Drehe dich, bis der Pfeil nach oben zeigt.';

  @override
  String get qibla_no_mosque =>
      'Wähle zuerst eine Moschee. Die Richtung wird für ihren Ort berechnet.';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_general => 'Allgemein';

  @override
  String get settings_appearance => 'Darstellung';

  @override
  String get settings_theme => 'Design';

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Hell';

  @override
  String get theme_dark => 'Dunkel';

  @override
  String get settings_accent => 'Akzentfarbe';

  @override
  String get settings_language => 'Sprache';

  @override
  String get settings_prayer => 'Gebetszeiten';

  @override
  String get settings_prayer_method => 'Berechnung';

  @override
  String get settings_data => 'Daten';

  @override
  String get settings_mode => 'Datenquelle';

  @override
  String get mode_test => 'Testdaten';

  @override
  String get mode_cloud => 'Cloud';

  @override
  String get mode_hint =>
      'Testdaten: erfundene Termine und Beiträge zum Ausprobieren. Cloud: echte Daten, sobald sie eingebaut ist.';

  @override
  String get mode_cloud_unavailable => 'Die Cloud ist noch nicht eingebaut.';

  @override
  String get settings_show_intro => 'Einführung ansehen';

  @override
  String get settings_reset => 'Einstellungen zurücksetzen';

  @override
  String get settings_about => 'Über die App';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_licenses => 'Lizenzen';

  @override
  String get account_sign_in => 'Anmelden';

  @override
  String get account_sign_in_hint => 'Für Beiträge in der Community';

  @override
  String get account_test => 'Testkonto · nur auf diesem Gerät';

  @override
  String get account_change_name => 'Namen ändern';

  @override
  String get account_change_email => 'E-Mail ändern';

  @override
  String get account_change_password => 'Passwort ändern';

  @override
  String get account_sign_out => 'Abmelden';

  @override
  String get account_delete => 'Konto löschen';

  @override
  String get account_delete_confirm =>
      'Dein Konto und deine Beiträge werden gelöscht.';

  @override
  String get account_not_in_test => 'In der Testversion noch nicht verfügbar.';

  @override
  String get intro_mosque_title => 'Deine Moschee in der Tasche';

  @override
  String get intro_mosque_body =>
      'Termine, Ankündigungen und Cenaze-Gebete deiner Moschee – direkt auf dem Handy.';

  @override
  String get intro_prayer_title => 'Gebetszeiten und Qibla';

  @override
  String get intro_prayer_body =>
      'Die Zeiten für deinen Ort nach Diyanet, dazu ein Kompass Richtung Mekka.';

  @override
  String get intro_nearby_title => 'Moscheen in der Nähe';

  @override
  String get intro_nearby_body =>
      'Alle Moscheen auf einer Karte. Feste und Veranstaltungen in deinem Umkreis auf einen Blick.';

  @override
  String get intro_community_title => 'Gemeinsam helfen';

  @override
  String get intro_community_body =>
      'Nachhilfe, Umzugshilfe, Babysitting: In der Community findest du Hilfe oder bietest sie an.';

  @override
  String get intro_start_title => 'Wie möchtest du starten?';

  @override
  String get intro_guest_title => 'Ohne Konto';

  @override
  String get intro_guest_1 => 'Termine, Gebetszeiten, Qibla und Karte';

  @override
  String get intro_guest_2 => 'Community-Beiträge lesen';

  @override
  String get intro_guest_3 => 'Keine persönlichen Daten nötig';

  @override
  String get intro_account_title => 'Mit Konto';

  @override
  String get intro_account_1 => 'Alles ohne Konto, dazu:';

  @override
  String get intro_account_2 => 'Beiträge in der Community erstellen';

  @override
  String get intro_account_3 => 'Interesse melden und Kontakt aufnehmen';

  @override
  String get intro_register => 'Registrieren';

  @override
  String get intro_login => 'Ich habe schon ein Konto';

  @override
  String get intro_guest => 'Ohne Konto fortfahren';

  @override
  String get intro_later_hint =>
      'Anmelden kannst du dich jederzeit später in den Einstellungen.';

  @override
  String get auth_login_title => 'Anmelden';

  @override
  String get auth_register_title => 'Registrieren';

  @override
  String get auth_name => 'Vorname';

  @override
  String get auth_email => 'E-Mail';

  @override
  String get auth_password => 'Passwort';

  @override
  String get auth_submit_login => 'Anmelden';

  @override
  String get auth_submit_register => 'Konto erstellen';

  @override
  String get auth_switch_to_register => 'Noch kein Konto? Registrieren';

  @override
  String get auth_switch_to_login => 'Schon ein Konto? Anmelden';

  @override
  String get auth_test_hint =>
      'Testmodus: Das Konto wird nur auf diesem Gerät simuliert. Es wird nichts gesendet.';

  @override
  String get auth_age_note =>
      'Mit der Registrierung bestätigst du, mindestens 16 Jahre alt zu sein.';

  @override
  String get auth_invalid_name => 'Bitte gib deinen Vornamen ein.';

  @override
  String get auth_invalid_email => 'Bitte gib eine gültige E-Mail ein.';

  @override
  String get auth_invalid_password => 'Mindestens 6 Zeichen.';

  @override
  String get nav_admin => 'Verwaltung';

  @override
  String get common_copied => 'Kopiert';

  @override
  String get common_saved => 'Gespeichert';

  @override
  String get location_use => 'Standort verwenden';

  @override
  String get location_hint =>
      'Für Qibla, Karte und Umkreis. Nur ungefähr, bleibt auf dem Gerät.';

  @override
  String get location_mine => 'Dein Standort';

  @override
  String get location_denied => 'Standort nicht freigegeben.';

  @override
  String get location_service_off => 'Die Standortdienste sind ausgeschaltet.';

  @override
  String get location_unavailable => 'Standort gerade nicht verfügbar.';

  @override
  String get location_open_settings => 'Einstellungen';

  @override
  String get radius_hint_location => 'Gemessen ab deinem Standort.';

  @override
  String get radius_off => 'Aus';

  @override
  String get mosques_radius => 'Umkreis';

  @override
  String get association_info_ditib =>
      'Türkisch-Islamische Union der Anstalt für Religion e. V. – größter Moscheeverband in Deutschland. Die Gemeinden sind eigenständige Vereine.';

  @override
  String get association_info_other => 'Verband, zu dem diese Moschee gehört.';

  @override
  String region_info(int number) {
    return 'Region $number des DITIB Landesjugendverbands Württemberg.';
  }

  @override
  String get admin_role_owner => 'Inhaber';

  @override
  String get admin_role_admin => 'Admin';

  @override
  String get admin_role_editor => 'Redakteur';

  @override
  String get admin_preview => 'Vorschau';

  @override
  String get admin_preview_setting => 'Verwaltung (Vorschau)';

  @override
  String get admin_preview_hint =>
      'Zeigt den Tab, den Moschee-Verantwortliche sehen – hier für deine Hauptmoschee.';

  @override
  String get admin_no_mosque => 'Wähle zuerst eine Hauptmoschee.';

  @override
  String get admin_view_page => 'Seite ansehen';

  @override
  String get admin_entries => 'Termine & Ankündigungen';

  @override
  String get admin_new_entry => 'Neuer Eintrag';

  @override
  String get admin_entries_empty => 'Noch keine Einträge.';

  @override
  String get admin_page => 'Moschee-Seite';

  @override
  String get admin_edit_info => 'Infos und Bild';

  @override
  String get admin_categories => 'Kategorien';

  @override
  String get admin_team => 'Team';

  @override
  String get admin_past => 'vorbei';

  @override
  String get admin_test_note =>
      'Änderungen gelten in den Testdaten bis zum Neustart der App.';

  @override
  String get entry_new => 'Neuer Eintrag';

  @override
  String get entry_edit => 'Eintrag bearbeiten';

  @override
  String get entry_category => 'Kategorie';

  @override
  String get entry_title => 'Titel';

  @override
  String get entry_body => 'Text';

  @override
  String get entry_has_date => 'Mit Termin';

  @override
  String get entry_date => 'Datum';

  @override
  String get entry_time => 'Uhrzeit';

  @override
  String get entry_notify => 'Mitglieder benachrichtigen';

  @override
  String get entry_notify_hint =>
      'Push-Nachricht, sobald die Cloud eingebaut ist.';

  @override
  String get entry_delete_confirm => 'Eintrag löschen?';

  @override
  String get entry_required => 'Bitte ausfüllen.';

  @override
  String get mosque_contact => 'Kontakt';

  @override
  String get mosque_edit_about => 'Beschreibung';

  @override
  String get mosque_edit_friday => 'Freitagsgebet';

  @override
  String get mosque_edit_phone => 'Telefon';

  @override
  String get mosque_edit_website => 'Webseite';

  @override
  String get mosque_edit_none => 'Keine Angabe';

  @override
  String get mosque_edit_locked =>
      'Name, Adresse und Siegel ändert die App-Leitung.';

  @override
  String get category_new => 'Neue Kategorie';

  @override
  String get category_edit => 'Kategorie bearbeiten';

  @override
  String get category_name => 'Name';

  @override
  String get category_color => 'Farbe';

  @override
  String get category_icon => 'Symbol';

  @override
  String get category_builtin => 'Standard';

  @override
  String get category_custom_hint =>
      'Standard-Kategorien gibt es überall. Eigene gelten nur für deine Moschee.';

  @override
  String get category_delete_confirm =>
      'Einträge dieser Kategorie werden zu „Veranstaltung“.';

  @override
  String get team_invite => 'Einladen';

  @override
  String get team_invite_title => 'Einladungscode';

  @override
  String get team_invite_message =>
      'Gib diesen Code an die Person weiter. Er gilt einmal und 7 Tage lang.';

  @override
  String get team_you => 'Du';

  @override
  String get team_roles_hint =>
      'Inhaber: alles, auch das Team. Admin: Seite, Termine, Kategorien. Redakteur: nur Termine und Ankündigungen.';

  @override
  String get team_remove => 'Entfernen';

  @override
  String get common_copy => 'Kopieren';

  @override
  String get category_own => 'Eigene';

  @override
  String get qibla_based_on_location => 'Berechnet für deinen Standort';
}
