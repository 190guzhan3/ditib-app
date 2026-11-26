import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @app_title.
  ///
  /// In de, this message translates to:
  /// **'Cemaat'**
  String get app_title;

  /// No description provided for @nav_home.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get nav_home;

  /// No description provided for @nav_mosques.
  ///
  /// In de, this message translates to:
  /// **'Moscheen'**
  String get nav_mosques;

  /// No description provided for @nav_community.
  ///
  /// In de, this message translates to:
  /// **'Community'**
  String get nav_community;

  /// No description provided for @common_cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get common_delete;

  /// No description provided for @common_save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get common_save;

  /// No description provided for @common_close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get common_close;

  /// No description provided for @common_continue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get common_continue;

  /// No description provided for @common_skip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get common_skip;

  /// No description provided for @common_show_all.
  ///
  /// In de, this message translates to:
  /// **'Alle anzeigen'**
  String get common_show_all;

  /// No description provided for @common_loading_please_wait.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment bitte …'**
  String get common_loading_please_wait;

  /// No description provided for @common_internet_required.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird eine Internetverbindung benötigt.'**
  String get common_internet_required;

  /// No description provided for @common_irreversible.
  ///
  /// In de, this message translates to:
  /// **'Das kann nicht rückgängig gemacht werden.'**
  String get common_irreversible;

  /// No description provided for @image_change.
  ///
  /// In de, this message translates to:
  /// **'Bild ändern'**
  String get image_change;

  /// No description provided for @image_choose.
  ///
  /// In de, this message translates to:
  /// **'Bild wählen'**
  String get image_choose;

  /// No description provided for @image_view.
  ///
  /// In de, this message translates to:
  /// **'Bild ansehen'**
  String get image_view;

  /// No description provided for @image_remove.
  ///
  /// In de, this message translates to:
  /// **'Bild entfernen'**
  String get image_remove;

  /// No description provided for @tooltip_qibla.
  ///
  /// In de, this message translates to:
  /// **'Qibla-Kompass'**
  String get tooltip_qibla;

  /// No description provided for @tooltip_settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get tooltip_settings;

  /// No description provided for @date_today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get date_today;

  /// No description provided for @date_tomorrow.
  ///
  /// In de, this message translates to:
  /// **'Morgen'**
  String get date_tomorrow;

  /// No description provided for @ago_now.
  ///
  /// In de, this message translates to:
  /// **'gerade eben'**
  String get ago_now;

  /// No description provided for @ago_minutes.
  ///
  /// In de, this message translates to:
  /// **'vor {n} Min.'**
  String ago_minutes(int n);

  /// No description provided for @ago_hours.
  ///
  /// In de, this message translates to:
  /// **'vor {n} Std.'**
  String ago_hours(int n);

  /// No description provided for @ago_days.
  ///
  /// In de, this message translates to:
  /// **'{n, plural, =1{vor 1 Tag} other{vor {n} Tagen}}'**
  String ago_days(int n);

  /// No description provided for @duration_hm.
  ///
  /// In de, this message translates to:
  /// **'{h} Std. {m} Min.'**
  String duration_hm(int h, int m);

  /// No description provided for @duration_m.
  ///
  /// In de, this message translates to:
  /// **'{m} Min.'**
  String duration_m(int m);

  /// No description provided for @distance_km.
  ///
  /// In de, this message translates to:
  /// **'{km} km'**
  String distance_km(String km);

  /// No description provided for @home_my_mosques.
  ///
  /// In de, this message translates to:
  /// **'Meine Moscheen'**
  String get home_my_mosques;

  /// No description provided for @home_add_mosque.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get home_add_mosque;

  /// No description provided for @home_no_mosque_title.
  ///
  /// In de, this message translates to:
  /// **'Wähle deine Moschee'**
  String get home_no_mosque_title;

  /// No description provided for @home_no_mosque_message.
  ///
  /// In de, this message translates to:
  /// **'Dann siehst du hier ihre Termine, Ankündigungen und Gebetszeiten.'**
  String get home_no_mosque_message;

  /// No description provided for @home_choose_mosque.
  ///
  /// In de, this message translates to:
  /// **'Moschee wählen'**
  String get home_choose_mosque;

  /// No description provided for @home_events.
  ///
  /// In de, this message translates to:
  /// **'Termine'**
  String get home_events;

  /// No description provided for @home_events_empty.
  ///
  /// In de, this message translates to:
  /// **'Keine anstehenden Termine.'**
  String get home_events_empty;

  /// No description provided for @home_notices.
  ///
  /// In de, this message translates to:
  /// **'Ankündigungen'**
  String get home_notices;

  /// No description provided for @home_nearby.
  ///
  /// In de, this message translates to:
  /// **'In der Umgebung'**
  String get home_nearby;

  /// No description provided for @home_nearby_count.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine weiteren Moscheen} =1{1 Moschee} other{{count} Moscheen}} im Umkreis von {km} km'**
  String home_nearby_count(int count, int km);

  /// No description provided for @home_nearby_empty.
  ///
  /// In de, this message translates to:
  /// **'Im Umkreis stehen keine Termine an. Vergrößere den Umkreis, um mehr zu sehen.'**
  String get home_nearby_empty;

  /// No description provided for @radius_title.
  ///
  /// In de, this message translates to:
  /// **'Umkreis'**
  String get radius_title;

  /// No description provided for @radius_hint.
  ///
  /// In de, this message translates to:
  /// **'Gemessen ab deiner Hauptmoschee ({name}).'**
  String radius_hint(String name);

  /// No description provided for @prayer_title.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten'**
  String get prayer_title;

  /// No description provided for @prayer_fajr.
  ///
  /// In de, this message translates to:
  /// **'Fadschr'**
  String get prayer_fajr;

  /// No description provided for @prayer_sunrise.
  ///
  /// In de, this message translates to:
  /// **'Sonne'**
  String get prayer_sunrise;

  /// No description provided for @prayer_dhuhr.
  ///
  /// In de, this message translates to:
  /// **'Dhuhr'**
  String get prayer_dhuhr;

  /// No description provided for @prayer_asr.
  ///
  /// In de, this message translates to:
  /// **'Asr'**
  String get prayer_asr;

  /// No description provided for @prayer_maghrib.
  ///
  /// In de, this message translates to:
  /// **'Maghrib'**
  String get prayer_maghrib;

  /// No description provided for @prayer_isha.
  ///
  /// In de, this message translates to:
  /// **'Ischa'**
  String get prayer_isha;

  /// No description provided for @prayer_next_in.
  ///
  /// In de, this message translates to:
  /// **'{prayer} in {duration}'**
  String prayer_next_in(String prayer, String duration);

  /// No description provided for @prayer_for.
  ///
  /// In de, this message translates to:
  /// **'{city} · {method}'**
  String prayer_for(String city, String method);

  /// No description provided for @prayer_friday.
  ///
  /// In de, this message translates to:
  /// **'Freitagsgebet {time}'**
  String prayer_friday(String time);

  /// No description provided for @prayer_method_diyanet.
  ///
  /// In de, this message translates to:
  /// **'Diyanet'**
  String get prayer_method_diyanet;

  /// No description provided for @prayer_method_muslimWorldLeague.
  ///
  /// In de, this message translates to:
  /// **'Muslim World League'**
  String get prayer_method_muslimWorldLeague;

  /// No description provided for @prayer_method_northAmerica.
  ///
  /// In de, this message translates to:
  /// **'ISNA (Nordamerika)'**
  String get prayer_method_northAmerica;

  /// No description provided for @kind_info.
  ///
  /// In de, this message translates to:
  /// **'Hinweis'**
  String get kind_info;

  /// No description provided for @kind_event.
  ///
  /// In de, this message translates to:
  /// **'Veranstaltung'**
  String get kind_event;

  /// No description provided for @kind_cenaze.
  ///
  /// In de, this message translates to:
  /// **'Cenaze'**
  String get kind_cenaze;

  /// No description provided for @kind_course.
  ///
  /// In de, this message translates to:
  /// **'Kurs'**
  String get kind_course;

  /// No description provided for @kind_festival.
  ///
  /// In de, this message translates to:
  /// **'Fest'**
  String get kind_festival;

  /// No description provided for @kind_youth.
  ///
  /// In de, this message translates to:
  /// **'Jugend'**
  String get kind_youth;

  /// No description provided for @announcement_open_mosque.
  ///
  /// In de, this message translates to:
  /// **'Zur Moschee'**
  String get announcement_open_mosque;

  /// No description provided for @mosques_search_hint.
  ///
  /// In de, this message translates to:
  /// **'Moschee oder Ort'**
  String get mosques_search_hint;

  /// No description provided for @mosques_view_map.
  ///
  /// In de, this message translates to:
  /// **'Karte'**
  String get mosques_view_map;

  /// No description provided for @mosques_view_list.
  ///
  /// In de, this message translates to:
  /// **'Liste'**
  String get mosques_view_list;

  /// No description provided for @mosques_all_regions.
  ///
  /// In de, this message translates to:
  /// **'Alle Regionen'**
  String get mosques_all_regions;

  /// No description provided for @mosques_only_radius.
  ///
  /// In de, this message translates to:
  /// **'Umkreis {km} km'**
  String mosques_only_radius(int km);

  /// No description provided for @mosques_empty.
  ///
  /// In de, this message translates to:
  /// **'Keine Moschee gefunden.'**
  String get mosques_empty;

  /// No description provided for @mosques_count.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Moschee} other{{count} Moscheen}}'**
  String mosques_count(int count);

  /// No description provided for @region_label.
  ///
  /// In de, this message translates to:
  /// **'Region {number}'**
  String region_label(int number);

  /// No description provided for @map_attribution.
  ///
  /// In de, this message translates to:
  /// **'© OpenStreetMap-Mitwirkende'**
  String get map_attribution;

  /// No description provided for @mosque_mine.
  ///
  /// In de, this message translates to:
  /// **'Meine Moschee'**
  String get mosque_mine;

  /// No description provided for @mosque_primary.
  ///
  /// In de, this message translates to:
  /// **'Hauptmoschee'**
  String get mosque_primary;

  /// No description provided for @mosque_add_mine.
  ///
  /// In de, this message translates to:
  /// **'Als meine Moschee'**
  String get mosque_add_mine;

  /// No description provided for @mosque_remove_mine.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get mosque_remove_mine;

  /// No description provided for @mosque_make_primary.
  ///
  /// In de, this message translates to:
  /// **'Als Hauptmoschee'**
  String get mosque_make_primary;

  /// No description provided for @mosque_verified.
  ///
  /// In de, this message translates to:
  /// **'Verifiziert'**
  String get mosque_verified;

  /// No description provided for @mosque_about.
  ///
  /// In de, this message translates to:
  /// **'Über die Moschee'**
  String get mosque_about;

  /// No description provided for @mosque_prayer_today.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten heute'**
  String get mosque_prayer_today;

  /// No description provided for @mosque_no_events.
  ///
  /// In de, this message translates to:
  /// **'Derzeit keine Termine.'**
  String get mosque_no_events;

  /// No description provided for @mosque_picker_title.
  ///
  /// In de, this message translates to:
  /// **'Moschee wählen'**
  String get mosque_picker_title;

  /// No description provided for @association_ditib.
  ///
  /// In de, this message translates to:
  /// **'DITIB'**
  String get association_ditib;

  /// No description provided for @association_igmg.
  ///
  /// In de, this message translates to:
  /// **'IGMG'**
  String get association_igmg;

  /// No description provided for @association_vikz.
  ///
  /// In de, this message translates to:
  /// **'VIKZ'**
  String get association_vikz;

  /// No description provided for @association_zmd.
  ///
  /// In de, this message translates to:
  /// **'ZMD'**
  String get association_zmd;

  /// No description provided for @association_independent.
  ///
  /// In de, this message translates to:
  /// **'Unabhängig'**
  String get association_independent;

  /// No description provided for @community_all.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get community_all;

  /// No description provided for @community_offers.
  ///
  /// In de, this message translates to:
  /// **'Biete'**
  String get community_offers;

  /// No description provided for @community_requests.
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get community_requests;

  /// No description provided for @community_sort_newest.
  ///
  /// In de, this message translates to:
  /// **'Neueste zuerst'**
  String get community_sort_newest;

  /// No description provided for @community_sort_nearby.
  ///
  /// In de, this message translates to:
  /// **'In der Nähe zuerst'**
  String get community_sort_nearby;

  /// No description provided for @community_all_categories.
  ///
  /// In de, this message translates to:
  /// **'Alle Kategorien'**
  String get community_all_categories;

  /// No description provided for @community_hint.
  ///
  /// In de, this message translates to:
  /// **'Nur Text, kein Chat: Kontaktdaten werden erst geteilt, wenn beide zustimmen.'**
  String get community_hint;

  /// No description provided for @community_empty.
  ///
  /// In de, this message translates to:
  /// **'Keine Beiträge für diese Auswahl.'**
  String get community_empty;

  /// No description provided for @category_education.
  ///
  /// In de, this message translates to:
  /// **'Lernen & Nachhilfe'**
  String get category_education;

  /// No description provided for @category_children.
  ///
  /// In de, this message translates to:
  /// **'Kinderbetreuung'**
  String get category_children;

  /// No description provided for @category_moving.
  ///
  /// In de, this message translates to:
  /// **'Umzug & Tragen'**
  String get category_moving;

  /// No description provided for @category_transport.
  ///
  /// In de, this message translates to:
  /// **'Fahrten'**
  String get category_transport;

  /// No description provided for @category_repair.
  ///
  /// In de, this message translates to:
  /// **'Handwerk & Technik'**
  String get category_repair;

  /// No description provided for @category_accompany.
  ///
  /// In de, this message translates to:
  /// **'Begleitung & Alltag'**
  String get category_accompany;

  /// No description provided for @category_giveaway.
  ///
  /// In de, this message translates to:
  /// **'Zu verschenken'**
  String get category_giveaway;

  /// No description provided for @category_other.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get category_other;

  /// No description provided for @post_offer.
  ///
  /// In de, this message translates to:
  /// **'Biete'**
  String get post_offer;

  /// No description provided for @post_request.
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get post_request;

  /// No description provided for @post_mine.
  ///
  /// In de, this message translates to:
  /// **'Dein Beitrag'**
  String get post_mine;

  /// No description provided for @post_interest.
  ///
  /// In de, this message translates to:
  /// **'Interesse melden'**
  String get post_interest;

  /// No description provided for @post_interest_done.
  ///
  /// In de, this message translates to:
  /// **'Interesse gemeldet'**
  String get post_interest_done;

  /// No description provided for @post_interest_count.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch niemand interessiert} =1{1 Person interessiert} other{{count} Personen interessiert}}'**
  String post_interest_count(int count);

  /// No description provided for @post_interest_sent.
  ///
  /// In de, this message translates to:
  /// **'Interesse gemeldet. Sobald {name} zustimmt, seht ihr gegenseitig eure Kontaktdaten.'**
  String post_interest_sent(String name);

  /// No description provided for @post_report.
  ///
  /// In de, this message translates to:
  /// **'Beitrag melden'**
  String get post_report;

  /// No description provided for @post_reported.
  ///
  /// In de, this message translates to:
  /// **'Danke, der Beitrag wird geprüft.'**
  String get post_reported;

  /// No description provided for @post_new.
  ///
  /// In de, this message translates to:
  /// **'Beitrag'**
  String get post_new;

  /// No description provided for @post_new_title.
  ///
  /// In de, this message translates to:
  /// **'Neuer Beitrag'**
  String get post_new_title;

  /// No description provided for @post_form_title.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get post_form_title;

  /// No description provided for @post_form_body.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get post_form_body;

  /// No description provided for @post_form_category.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get post_form_category;

  /// No description provided for @post_form_mosque.
  ///
  /// In de, this message translates to:
  /// **'Gemeinde'**
  String get post_form_mosque;

  /// No description provided for @post_form_rules.
  ///
  /// In de, this message translates to:
  /// **'Bitte keine Telefonnummern, Adressen oder gewerblichen Angebote. Beiträge können gemeldet werden.'**
  String get post_form_rules;

  /// No description provided for @post_form_publish.
  ///
  /// In de, this message translates to:
  /// **'Veröffentlichen'**
  String get post_form_publish;

  /// No description provided for @post_form_required.
  ///
  /// In de, this message translates to:
  /// **'Bitte ausfüllen.'**
  String get post_form_required;

  /// No description provided for @post_created.
  ///
  /// In de, this message translates to:
  /// **'Beitrag veröffentlicht.'**
  String get post_created;

  /// No description provided for @account_needed_title.
  ///
  /// In de, this message translates to:
  /// **'Dafür brauchst du ein Konto'**
  String get account_needed_title;

  /// No description provided for @account_needed_message.
  ///
  /// In de, this message translates to:
  /// **'Lesen geht ohne Konto. Um Beiträge zu erstellen oder Interesse zu melden, brauchst du ein Konto. So bleibt die Community sicher.'**
  String get account_needed_message;

  /// No description provided for @qibla_title.
  ///
  /// In de, this message translates to:
  /// **'Qibla'**
  String get qibla_title;

  /// No description provided for @qibla_degrees.
  ///
  /// In de, this message translates to:
  /// **'{degrees}° von Norden'**
  String qibla_degrees(int degrees);

  /// No description provided for @qibla_based_on.
  ///
  /// In de, this message translates to:
  /// **'Berechnet für {place}'**
  String qibla_based_on(String place);

  /// No description provided for @qibla_no_sensor.
  ///
  /// In de, this message translates to:
  /// **'Kein Kompass verfügbar. Richte das Handy nach Norden aus, dann zeigt der Pfeil Richtung Mekka.'**
  String get qibla_no_sensor;

  /// No description provided for @qibla_calibrate.
  ///
  /// In de, this message translates to:
  /// **'Für genaue Werte das Handy flach halten und einmal in einer Acht bewegen.'**
  String get qibla_calibrate;

  /// No description provided for @qibla_aligned.
  ///
  /// In de, this message translates to:
  /// **'Richtung stimmt'**
  String get qibla_aligned;

  /// No description provided for @qibla_turn.
  ///
  /// In de, this message translates to:
  /// **'Drehe dich, bis der Pfeil nach oben zeigt.'**
  String get qibla_turn;

  /// No description provided for @qibla_no_mosque.
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst eine Moschee. Die Richtung wird für ihren Ort berechnet.'**
  String get qibla_no_mosque;

  /// No description provided for @settings_title.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get settings_general;

  /// No description provided for @settings_appearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get settings_appearance;

  /// No description provided for @settings_theme.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get settings_theme;

  /// No description provided for @theme_system.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get theme_dark;

  /// No description provided for @settings_accent.
  ///
  /// In de, this message translates to:
  /// **'Akzentfarbe'**
  String get settings_accent;

  /// No description provided for @settings_language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settings_language;

  /// No description provided for @settings_prayer.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten'**
  String get settings_prayer;

  /// No description provided for @settings_prayer_method.
  ///
  /// In de, this message translates to:
  /// **'Berechnung'**
  String get settings_prayer_method;

  /// No description provided for @settings_data.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get settings_data;

  /// No description provided for @settings_mode.
  ///
  /// In de, this message translates to:
  /// **'Datenquelle'**
  String get settings_mode;

  /// No description provided for @mode_test.
  ///
  /// In de, this message translates to:
  /// **'Testdaten'**
  String get mode_test;

  /// No description provided for @mode_cloud.
  ///
  /// In de, this message translates to:
  /// **'Cloud'**
  String get mode_cloud;

  /// No description provided for @mode_hint.
  ///
  /// In de, this message translates to:
  /// **'Testdaten: erfundene Termine und Beiträge zum Ausprobieren. Cloud: echte Daten, sobald sie eingebaut ist.'**
  String get mode_hint;

  /// No description provided for @mode_cloud_unavailable.
  ///
  /// In de, this message translates to:
  /// **'Die Cloud ist noch nicht eingebaut.'**
  String get mode_cloud_unavailable;

  /// No description provided for @settings_show_intro.
  ///
  /// In de, this message translates to:
  /// **'Einführung ansehen'**
  String get settings_show_intro;

  /// No description provided for @settings_reset.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen zurücksetzen'**
  String get settings_reset;

  /// No description provided for @settings_about.
  ///
  /// In de, this message translates to:
  /// **'Über die App'**
  String get settings_about;

  /// No description provided for @settings_version.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_licenses.
  ///
  /// In de, this message translates to:
  /// **'Lizenzen'**
  String get settings_licenses;

  /// No description provided for @account_sign_in.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get account_sign_in;

  /// No description provided for @account_sign_in_hint.
  ///
  /// In de, this message translates to:
  /// **'Für Beiträge in der Community'**
  String get account_sign_in_hint;

  /// No description provided for @account_test.
  ///
  /// In de, this message translates to:
  /// **'Testkonto · nur auf diesem Gerät'**
  String get account_test;

  /// No description provided for @account_change_name.
  ///
  /// In de, this message translates to:
  /// **'Namen ändern'**
  String get account_change_name;

  /// No description provided for @account_change_email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail ändern'**
  String get account_change_email;

  /// No description provided for @account_change_password.
  ///
  /// In de, this message translates to:
  /// **'Passwort ändern'**
  String get account_change_password;

  /// No description provided for @account_sign_out.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get account_sign_out;

  /// No description provided for @account_delete.
  ///
  /// In de, this message translates to:
  /// **'Konto löschen'**
  String get account_delete;

  /// No description provided for @account_delete_confirm.
  ///
  /// In de, this message translates to:
  /// **'Dein Konto und deine Beiträge werden gelöscht.'**
  String get account_delete_confirm;

  /// No description provided for @account_not_in_test.
  ///
  /// In de, this message translates to:
  /// **'In der Testversion noch nicht verfügbar.'**
  String get account_not_in_test;

  /// No description provided for @intro_mosque_title.
  ///
  /// In de, this message translates to:
  /// **'Deine Moschee in der Tasche'**
  String get intro_mosque_title;

  /// No description provided for @intro_mosque_body.
  ///
  /// In de, this message translates to:
  /// **'Termine, Ankündigungen und Cenaze-Gebete deiner Moschee – direkt auf dem Handy.'**
  String get intro_mosque_body;

  /// No description provided for @intro_prayer_title.
  ///
  /// In de, this message translates to:
  /// **'Gebetszeiten und Qibla'**
  String get intro_prayer_title;

  /// No description provided for @intro_prayer_body.
  ///
  /// In de, this message translates to:
  /// **'Die Zeiten für deinen Ort nach Diyanet, dazu ein Kompass Richtung Mekka.'**
  String get intro_prayer_body;

  /// No description provided for @intro_nearby_title.
  ///
  /// In de, this message translates to:
  /// **'Moscheen in der Nähe'**
  String get intro_nearby_title;

  /// No description provided for @intro_nearby_body.
  ///
  /// In de, this message translates to:
  /// **'Alle Moscheen auf einer Karte. Feste und Veranstaltungen in deinem Umkreis auf einen Blick.'**
  String get intro_nearby_body;

  /// No description provided for @intro_community_title.
  ///
  /// In de, this message translates to:
  /// **'Gemeinsam helfen'**
  String get intro_community_title;

  /// No description provided for @intro_community_body.
  ///
  /// In de, this message translates to:
  /// **'Nachhilfe, Umzugshilfe, Babysitting: In der Community findest du Hilfe oder bietest sie an.'**
  String get intro_community_body;

  /// No description provided for @intro_start_title.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du starten?'**
  String get intro_start_title;

  /// No description provided for @intro_guest_title.
  ///
  /// In de, this message translates to:
  /// **'Ohne Konto'**
  String get intro_guest_title;

  /// No description provided for @intro_guest_1.
  ///
  /// In de, this message translates to:
  /// **'Termine, Gebetszeiten, Qibla und Karte'**
  String get intro_guest_1;

  /// No description provided for @intro_guest_2.
  ///
  /// In de, this message translates to:
  /// **'Community-Beiträge lesen'**
  String get intro_guest_2;

  /// No description provided for @intro_guest_3.
  ///
  /// In de, this message translates to:
  /// **'Keine persönlichen Daten nötig'**
  String get intro_guest_3;

  /// No description provided for @intro_account_title.
  ///
  /// In de, this message translates to:
  /// **'Mit Konto'**
  String get intro_account_title;

  /// No description provided for @intro_account_1.
  ///
  /// In de, this message translates to:
  /// **'Alles ohne Konto, dazu:'**
  String get intro_account_1;

  /// No description provided for @intro_account_2.
  ///
  /// In de, this message translates to:
  /// **'Beiträge in der Community erstellen'**
  String get intro_account_2;

  /// No description provided for @intro_account_3.
  ///
  /// In de, this message translates to:
  /// **'Interesse melden und Kontakt aufnehmen'**
  String get intro_account_3;

  /// No description provided for @intro_register.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get intro_register;

  /// No description provided for @intro_login.
  ///
  /// In de, this message translates to:
  /// **'Ich habe schon ein Konto'**
  String get intro_login;

  /// No description provided for @intro_guest.
  ///
  /// In de, this message translates to:
  /// **'Ohne Konto fortfahren'**
  String get intro_guest;

  /// No description provided for @intro_later_hint.
  ///
  /// In de, this message translates to:
  /// **'Anmelden kannst du dich jederzeit später in den Einstellungen.'**
  String get intro_later_hint;

  /// No description provided for @auth_login_title.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get auth_login_title;

  /// No description provided for @auth_register_title.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get auth_register_title;

  /// No description provided for @auth_name.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get auth_name;

  /// No description provided for @auth_email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get auth_password;

  /// No description provided for @auth_submit_login.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get auth_submit_login;

  /// No description provided for @auth_submit_register.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get auth_submit_register;

  /// No description provided for @auth_switch_to_register.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto? Registrieren'**
  String get auth_switch_to_register;

  /// No description provided for @auth_switch_to_login.
  ///
  /// In de, this message translates to:
  /// **'Schon ein Konto? Anmelden'**
  String get auth_switch_to_login;

  /// No description provided for @auth_test_hint.
  ///
  /// In de, this message translates to:
  /// **'Testmodus: Das Konto wird nur auf diesem Gerät simuliert. Es wird nichts gesendet.'**
  String get auth_test_hint;

  /// No description provided for @auth_age_note.
  ///
  /// In de, this message translates to:
  /// **'Mit der Registrierung bestätigst du, mindestens 16 Jahre alt zu sein.'**
  String get auth_age_note;

  /// No description provided for @auth_invalid_name.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deinen Vornamen ein.'**
  String get auth_invalid_name;

  /// No description provided for @auth_invalid_email.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine gültige E-Mail ein.'**
  String get auth_invalid_email;

  /// No description provided for @auth_invalid_password.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 6 Zeichen.'**
  String get auth_invalid_password;

  /// No description provided for @nav_admin.
  ///
  /// In de, this message translates to:
  /// **'Verwaltung'**
  String get nav_admin;

  /// No description provided for @common_copied.
  ///
  /// In de, this message translates to:
  /// **'Kopiert'**
  String get common_copied;

  /// No description provided for @common_saved.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert'**
  String get common_saved;

  /// No description provided for @location_use.
  ///
  /// In de, this message translates to:
  /// **'Standort verwenden'**
  String get location_use;

  /// No description provided for @location_hint.
  ///
  /// In de, this message translates to:
  /// **'Für Qibla, Karte und Umkreis. Nur ungefähr, bleibt auf dem Gerät.'**
  String get location_hint;

  /// No description provided for @location_mine.
  ///
  /// In de, this message translates to:
  /// **'Dein Standort'**
  String get location_mine;

  /// No description provided for @location_denied.
  ///
  /// In de, this message translates to:
  /// **'Standort nicht freigegeben.'**
  String get location_denied;

  /// No description provided for @location_service_off.
  ///
  /// In de, this message translates to:
  /// **'Die Standortdienste sind ausgeschaltet.'**
  String get location_service_off;

  /// No description provided for @location_unavailable.
  ///
  /// In de, this message translates to:
  /// **'Standort gerade nicht verfügbar.'**
  String get location_unavailable;

  /// No description provided for @location_open_settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get location_open_settings;

  /// No description provided for @radius_hint_location.
  ///
  /// In de, this message translates to:
  /// **'Gemessen ab deinem Standort.'**
  String get radius_hint_location;

  /// No description provided for @radius_off.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get radius_off;

  /// No description provided for @mosques_radius.
  ///
  /// In de, this message translates to:
  /// **'Umkreis'**
  String get mosques_radius;

  /// No description provided for @association_info_ditib.
  ///
  /// In de, this message translates to:
  /// **'Türkisch-Islamische Union der Anstalt für Religion e. V. – größter Moscheeverband in Deutschland. Die Gemeinden sind eigenständige Vereine.'**
  String get association_info_ditib;

  /// No description provided for @association_info_other.
  ///
  /// In de, this message translates to:
  /// **'Verband, zu dem diese Moschee gehört.'**
  String get association_info_other;

  /// No description provided for @region_info.
  ///
  /// In de, this message translates to:
  /// **'Region {number} des DITIB Landesjugendverbands Württemberg.'**
  String region_info(int number);

  /// No description provided for @admin_role_owner.
  ///
  /// In de, this message translates to:
  /// **'Inhaber'**
  String get admin_role_owner;

  /// No description provided for @admin_role_admin.
  ///
  /// In de, this message translates to:
  /// **'Admin'**
  String get admin_role_admin;

  /// No description provided for @admin_role_editor.
  ///
  /// In de, this message translates to:
  /// **'Redakteur'**
  String get admin_role_editor;

  /// No description provided for @admin_preview.
  ///
  /// In de, this message translates to:
  /// **'Vorschau'**
  String get admin_preview;

  /// No description provided for @admin_preview_setting.
  ///
  /// In de, this message translates to:
  /// **'Verwaltung (Vorschau)'**
  String get admin_preview_setting;

  /// No description provided for @admin_preview_hint.
  ///
  /// In de, this message translates to:
  /// **'Zeigt den Tab, den Moschee-Verantwortliche sehen – hier für deine Hauptmoschee.'**
  String get admin_preview_hint;

  /// No description provided for @admin_no_mosque.
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst eine Hauptmoschee.'**
  String get admin_no_mosque;

  /// No description provided for @admin_view_page.
  ///
  /// In de, this message translates to:
  /// **'Seite ansehen'**
  String get admin_view_page;

  /// No description provided for @admin_entries.
  ///
  /// In de, this message translates to:
  /// **'Termine & Ankündigungen'**
  String get admin_entries;

  /// No description provided for @admin_new_entry.
  ///
  /// In de, this message translates to:
  /// **'Neuer Eintrag'**
  String get admin_new_entry;

  /// No description provided for @admin_entries_empty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge.'**
  String get admin_entries_empty;

  /// No description provided for @admin_page.
  ///
  /// In de, this message translates to:
  /// **'Moschee-Seite'**
  String get admin_page;

  /// No description provided for @admin_edit_info.
  ///
  /// In de, this message translates to:
  /// **'Infos und Bild'**
  String get admin_edit_info;

  /// No description provided for @admin_categories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get admin_categories;

  /// No description provided for @admin_team.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get admin_team;

  /// No description provided for @admin_past.
  ///
  /// In de, this message translates to:
  /// **'vorbei'**
  String get admin_past;

  /// No description provided for @admin_test_note.
  ///
  /// In de, this message translates to:
  /// **'Änderungen gelten in den Testdaten bis zum Neustart der App.'**
  String get admin_test_note;

  /// No description provided for @entry_new.
  ///
  /// In de, this message translates to:
  /// **'Neuer Eintrag'**
  String get entry_new;

  /// No description provided for @entry_edit.
  ///
  /// In de, this message translates to:
  /// **'Eintrag bearbeiten'**
  String get entry_edit;

  /// No description provided for @entry_category.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get entry_category;

  /// No description provided for @entry_title.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get entry_title;

  /// No description provided for @entry_body.
  ///
  /// In de, this message translates to:
  /// **'Text'**
  String get entry_body;

  /// No description provided for @entry_has_date.
  ///
  /// In de, this message translates to:
  /// **'Mit Termin'**
  String get entry_has_date;

  /// No description provided for @entry_date.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get entry_date;

  /// No description provided for @entry_time.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit'**
  String get entry_time;

  /// No description provided for @entry_notify.
  ///
  /// In de, this message translates to:
  /// **'Mitglieder benachrichtigen'**
  String get entry_notify;

  /// No description provided for @entry_notify_hint.
  ///
  /// In de, this message translates to:
  /// **'Push-Nachricht, sobald die Cloud eingebaut ist.'**
  String get entry_notify_hint;

  /// No description provided for @entry_delete_confirm.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen?'**
  String get entry_delete_confirm;

  /// No description provided for @entry_required.
  ///
  /// In de, this message translates to:
  /// **'Bitte ausfüllen.'**
  String get entry_required;

  /// No description provided for @mosque_contact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get mosque_contact;

  /// No description provided for @mosque_edit_about.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get mosque_edit_about;

  /// No description provided for @mosque_edit_friday.
  ///
  /// In de, this message translates to:
  /// **'Freitagsgebet'**
  String get mosque_edit_friday;

  /// No description provided for @mosque_edit_phone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get mosque_edit_phone;

  /// No description provided for @mosque_edit_website.
  ///
  /// In de, this message translates to:
  /// **'Webseite'**
  String get mosque_edit_website;

  /// No description provided for @mosque_edit_none.
  ///
  /// In de, this message translates to:
  /// **'Keine Angabe'**
  String get mosque_edit_none;

  /// No description provided for @mosque_edit_locked.
  ///
  /// In de, this message translates to:
  /// **'Name, Adresse und Siegel ändert die App-Leitung.'**
  String get mosque_edit_locked;

  /// No description provided for @category_new.
  ///
  /// In de, this message translates to:
  /// **'Neue Kategorie'**
  String get category_new;

  /// No description provided for @category_edit.
  ///
  /// In de, this message translates to:
  /// **'Kategorie bearbeiten'**
  String get category_edit;

  /// No description provided for @category_name.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get category_name;

  /// No description provided for @category_color.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get category_color;

  /// No description provided for @category_icon.
  ///
  /// In de, this message translates to:
  /// **'Symbol'**
  String get category_icon;

  /// No description provided for @category_builtin.
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get category_builtin;

  /// No description provided for @category_custom_hint.
  ///
  /// In de, this message translates to:
  /// **'Standard-Kategorien gibt es überall. Eigene gelten nur für deine Moschee.'**
  String get category_custom_hint;

  /// No description provided for @category_delete_confirm.
  ///
  /// In de, this message translates to:
  /// **'Einträge dieser Kategorie werden zu „Veranstaltung“.'**
  String get category_delete_confirm;

  /// No description provided for @team_invite.
  ///
  /// In de, this message translates to:
  /// **'Einladen'**
  String get team_invite;

  /// No description provided for @team_invite_title.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode'**
  String get team_invite_title;

  /// No description provided for @team_invite_message.
  ///
  /// In de, this message translates to:
  /// **'Gib diesen Code an die Person weiter. Er gilt einmal und 7 Tage lang.'**
  String get team_invite_message;

  /// No description provided for @team_you.
  ///
  /// In de, this message translates to:
  /// **'Du'**
  String get team_you;

  /// No description provided for @team_roles_hint.
  ///
  /// In de, this message translates to:
  /// **'Inhaber: alles, auch das Team. Admin: Seite, Termine, Kategorien. Redakteur: nur Termine und Ankündigungen.'**
  String get team_roles_hint;

  /// No description provided for @team_remove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get team_remove;

  /// No description provided for @common_copy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get common_copy;

  /// No description provided for @category_own.
  ///
  /// In de, this message translates to:
  /// **'Eigene'**
  String get category_own;

  /// No description provided for @qibla_based_on_location.
  ///
  /// In de, this message translates to:
  /// **'Berechnet für deinen Standort'**
  String get qibla_based_on_location;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
