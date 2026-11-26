// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Cemaat';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_mosques => 'Mosques';

  @override
  String get nav_community => 'Community';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_save => 'Save';

  @override
  String get common_close => 'Close';

  @override
  String get common_continue => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_show_all => 'Show all';

  @override
  String get common_loading_please_wait => 'One moment please …';

  @override
  String get common_internet_required =>
      'An internet connection is required for this.';

  @override
  String get common_irreversible => 'This cannot be undone.';

  @override
  String get image_change => 'Change image';

  @override
  String get image_choose => 'Choose image';

  @override
  String get image_view => 'View image';

  @override
  String get image_remove => 'Remove image';

  @override
  String get tooltip_qibla => 'Qibla compass';

  @override
  String get tooltip_settings => 'Settings';

  @override
  String get date_today => 'Today';

  @override
  String get date_tomorrow => 'Tomorrow';

  @override
  String get ago_now => 'just now';

  @override
  String ago_minutes(int n) {
    return '$n min ago';
  }

  @override
  String ago_hours(int n) {
    return '$n h ago';
  }

  @override
  String ago_days(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String duration_hm(int h, int m) {
    return '$h h $m min';
  }

  @override
  String duration_m(int m) {
    return '$m min';
  }

  @override
  String distance_km(String km) {
    return '$km km';
  }

  @override
  String get home_my_mosques => 'My mosques';

  @override
  String get home_add_mosque => 'Add';

  @override
  String get home_no_mosque_title => 'Choose your mosque';

  @override
  String get home_no_mosque_message =>
      'You\'ll then see its events, announcements and prayer times here.';

  @override
  String get home_choose_mosque => 'Choose mosque';

  @override
  String get home_events => 'Events';

  @override
  String get home_events_empty => 'No upcoming events.';

  @override
  String get home_notices => 'Announcements';

  @override
  String get home_nearby => 'Nearby';

  @override
  String home_nearby_count(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mosques',
      one: '1 mosque',
      zero: 'No other mosques',
    );
    return '$_temp0 within $km km';
  }

  @override
  String get home_nearby_empty =>
      'No upcoming events nearby. Increase the radius to see more.';

  @override
  String get radius_title => 'Radius';

  @override
  String radius_hint(String name) {
    return 'Measured from your main mosque ($name).';
  }

  @override
  String get prayer_title => 'Prayer times';

  @override
  String get prayer_fajr => 'Fajr';

  @override
  String get prayer_sunrise => 'Sunrise';

  @override
  String get prayer_dhuhr => 'Dhuhr';

  @override
  String get prayer_asr => 'Asr';

  @override
  String get prayer_maghrib => 'Maghrib';

  @override
  String get prayer_isha => 'Isha';

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
    return 'Friday prayer $time';
  }

  @override
  String get prayer_method_diyanet => 'Diyanet';

  @override
  String get prayer_method_muslimWorldLeague => 'Muslim World League';

  @override
  String get prayer_method_northAmerica => 'ISNA (North America)';

  @override
  String get kind_info => 'Notice';

  @override
  String get kind_event => 'Event';

  @override
  String get kind_cenaze => 'Funeral prayer';

  @override
  String get kind_course => 'Course';

  @override
  String get kind_festival => 'Festival';

  @override
  String get kind_youth => 'Youth';

  @override
  String get announcement_open_mosque => 'Go to mosque';

  @override
  String get mosques_search_hint => 'Mosque or town';

  @override
  String get mosques_view_map => 'Map';

  @override
  String get mosques_view_list => 'List';

  @override
  String get mosques_all_regions => 'All regions';

  @override
  String mosques_only_radius(int km) {
    return 'Within $km km';
  }

  @override
  String get mosques_empty => 'No mosque found.';

  @override
  String mosques_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mosques',
      one: '1 mosque',
    );
    return '$_temp0';
  }

  @override
  String region_label(int number) {
    return 'Region $number';
  }

  @override
  String get map_attribution => '© OpenStreetMap contributors';

  @override
  String get mosque_mine => 'My mosque';

  @override
  String get mosque_primary => 'Main mosque';

  @override
  String get mosque_add_mine => 'Add as my mosque';

  @override
  String get mosque_remove_mine => 'Remove';

  @override
  String get mosque_make_primary => 'Make main mosque';

  @override
  String get mosque_verified => 'Verified';

  @override
  String get mosque_about => 'About the mosque';

  @override
  String get mosque_prayer_today => 'Prayer times today';

  @override
  String get mosque_no_events => 'No events at the moment.';

  @override
  String get mosque_picker_title => 'Choose mosque';

  @override
  String get association_ditib => 'DITIB';

  @override
  String get association_igmg => 'IGMG';

  @override
  String get association_vikz => 'VIKZ';

  @override
  String get association_zmd => 'ZMD';

  @override
  String get association_independent => 'Independent';

  @override
  String get community_all => 'All';

  @override
  String get community_offers => 'Offering';

  @override
  String get community_requests => 'Looking for';

  @override
  String get community_sort_newest => 'Newest first';

  @override
  String get community_sort_nearby => 'Nearest first';

  @override
  String get community_all_categories => 'All categories';

  @override
  String get community_hint =>
      'Text only, no chat: contact details are shared only when both agree.';

  @override
  String get community_empty => 'No posts for this selection.';

  @override
  String get category_education => 'Learning & tutoring';

  @override
  String get category_children => 'Childcare';

  @override
  String get category_moving => 'Moving & carrying';

  @override
  String get category_transport => 'Rides';

  @override
  String get category_repair => 'Repairs & tech';

  @override
  String get category_accompany => 'Company & everyday help';

  @override
  String get category_giveaway => 'Free to give away';

  @override
  String get category_other => 'Other';

  @override
  String get post_offer => 'Offering';

  @override
  String get post_request => 'Looking for';

  @override
  String get post_mine => 'Your post';

  @override
  String get post_interest => 'I\'m interested';

  @override
  String get post_interest_done => 'Interest sent';

  @override
  String post_interest_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people interested',
      one: '1 person interested',
      zero: 'Nobody interested yet',
    );
    return '$_temp0';
  }

  @override
  String post_interest_sent(String name) {
    return 'Interest sent. Once $name agrees, you\'ll both see each other\'s contact details.';
  }

  @override
  String get post_report => 'Report post';

  @override
  String get post_reported => 'Thank you, the post will be reviewed.';

  @override
  String get post_new => 'Post';

  @override
  String get post_new_title => 'New post';

  @override
  String get post_form_title => 'Title';

  @override
  String get post_form_body => 'Description';

  @override
  String get post_form_category => 'Category';

  @override
  String get post_form_mosque => 'Community';

  @override
  String get post_form_rules =>
      'Please no phone numbers, addresses or commercial offers. Posts can be reported.';

  @override
  String get post_form_publish => 'Publish';

  @override
  String get post_form_required => 'Please fill in.';

  @override
  String get post_created => 'Post published.';

  @override
  String get account_needed_title => 'You need an account for this';

  @override
  String get account_needed_message =>
      'Reading works without an account. To create posts or show interest you need an account. This keeps the community safe.';

  @override
  String get qibla_title => 'Qibla';

  @override
  String qibla_degrees(int degrees) {
    return '$degrees° from north';
  }

  @override
  String qibla_based_on(String place) {
    return 'Calculated for $place';
  }

  @override
  String get qibla_no_sensor =>
      'No compass available. Point your phone north; the arrow then points towards Mecca.';

  @override
  String get qibla_calibrate =>
      'For accurate values hold the phone flat and move it in a figure eight once.';

  @override
  String get qibla_aligned => 'Direction is right';

  @override
  String get qibla_turn => 'Turn until the arrow points up.';

  @override
  String get qibla_no_mosque =>
      'Choose a mosque first. The direction is calculated for its location.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general => 'General';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_theme => 'Theme';

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get settings_accent => 'Accent colour';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_prayer => 'Prayer times';

  @override
  String get settings_prayer_method => 'Calculation';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_mode => 'Data source';

  @override
  String get mode_test => 'Test data';

  @override
  String get mode_cloud => 'Cloud';

  @override
  String get mode_hint =>
      'Test data: made-up events and posts to try things out. Cloud: real data, once it is built in.';

  @override
  String get mode_cloud_unavailable => 'The cloud is not built in yet.';

  @override
  String get settings_show_intro => 'Show introduction';

  @override
  String get settings_reset => 'Reset settings';

  @override
  String get settings_about => 'About the app';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_licenses => 'Licences';

  @override
  String get account_sign_in => 'Sign in';

  @override
  String get account_sign_in_hint => 'For posts in the community';

  @override
  String get account_test => 'Test account · this device only';

  @override
  String get account_change_name => 'Change name';

  @override
  String get account_change_email => 'Change email';

  @override
  String get account_change_password => 'Change password';

  @override
  String get account_sign_out => 'Sign out';

  @override
  String get account_delete => 'Delete account';

  @override
  String get account_delete_confirm =>
      'Your account and your posts will be deleted.';

  @override
  String get account_not_in_test => 'Not available in the test version yet.';

  @override
  String get intro_mosque_title => 'Your mosque in your pocket';

  @override
  String get intro_mosque_body =>
      'Events, announcements and funeral prayers of your mosque – right on your phone.';

  @override
  String get intro_prayer_title => 'Prayer times and Qibla';

  @override
  String get intro_prayer_body =>
      'Times for your location according to Diyanet, plus a compass towards Mecca.';

  @override
  String get intro_nearby_title => 'Mosques nearby';

  @override
  String get intro_nearby_body =>
      'All mosques on one map. Festivals and events around you at a glance.';

  @override
  String get intro_community_title => 'Helping each other';

  @override
  String get intro_community_body =>
      'Tutoring, help with moving, babysitting: find help in the community or offer it.';

  @override
  String get intro_start_title => 'How would you like to start?';

  @override
  String get intro_guest_title => 'Without account';

  @override
  String get intro_guest_1 => 'Events, prayer times, Qibla and map';

  @override
  String get intro_guest_2 => 'Read community posts';

  @override
  String get intro_guest_3 => 'No personal data needed';

  @override
  String get intro_account_title => 'With account';

  @override
  String get intro_account_1 => 'Everything without account, plus:';

  @override
  String get intro_account_2 => 'Create posts in the community';

  @override
  String get intro_account_3 => 'Show interest and get in touch';

  @override
  String get intro_register => 'Register';

  @override
  String get intro_login => 'I already have an account';

  @override
  String get intro_guest => 'Continue without account';

  @override
  String get intro_later_hint =>
      'You can sign in any time later in the settings.';

  @override
  String get auth_login_title => 'Sign in';

  @override
  String get auth_register_title => 'Register';

  @override
  String get auth_name => 'First name';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_submit_login => 'Sign in';

  @override
  String get auth_submit_register => 'Create account';

  @override
  String get auth_switch_to_register => 'No account yet? Register';

  @override
  String get auth_switch_to_login => 'Already have an account? Sign in';

  @override
  String get auth_test_hint =>
      'Test mode: the account is only simulated on this device. Nothing is sent.';

  @override
  String get auth_age_note =>
      'By registering you confirm that you are at least 16 years old.';

  @override
  String get auth_invalid_name => 'Please enter your first name.';

  @override
  String get auth_invalid_email => 'Please enter a valid email.';

  @override
  String get auth_invalid_password => 'At least 6 characters.';

  @override
  String get nav_admin => 'Manage';

  @override
  String get common_copied => 'Copied';

  @override
  String get common_saved => 'Saved';

  @override
  String get location_use => 'Use location';

  @override
  String get location_hint =>
      'For Qibla, map and radius. Approximate only, stays on your device.';

  @override
  String get location_mine => 'Your location';

  @override
  String get location_denied => 'Location not allowed.';

  @override
  String get location_service_off => 'Location services are turned off.';

  @override
  String get location_unavailable => 'Location currently unavailable.';

  @override
  String get location_open_settings => 'Settings';

  @override
  String get radius_hint_location => 'Measured from your location.';

  @override
  String get radius_off => 'Off';

  @override
  String get mosques_radius => 'Radius';

  @override
  String get association_info_ditib =>
      'Turkish-Islamic Union for Religious Affairs – the largest mosque association in Germany. Its communities are independent associations.';

  @override
  String get association_info_other => 'Association this mosque belongs to.';

  @override
  String region_info(int number) {
    return 'Region $number of the DITIB youth association Württemberg.';
  }

  @override
  String get admin_role_owner => 'Owner';

  @override
  String get admin_role_admin => 'Admin';

  @override
  String get admin_role_editor => 'Editor';

  @override
  String get admin_preview => 'Preview';

  @override
  String get admin_preview_setting => 'Management (preview)';

  @override
  String get admin_preview_hint =>
      'Shows the tab mosque managers see – here for your main mosque.';

  @override
  String get admin_no_mosque => 'Choose a main mosque first.';

  @override
  String get admin_view_page => 'View page';

  @override
  String get admin_entries => 'Events & announcements';

  @override
  String get admin_new_entry => 'New entry';

  @override
  String get admin_entries_empty => 'No entries yet.';

  @override
  String get admin_page => 'Mosque page';

  @override
  String get admin_edit_info => 'Info and picture';

  @override
  String get admin_categories => 'Categories';

  @override
  String get admin_team => 'Team';

  @override
  String get admin_past => 'past';

  @override
  String get admin_test_note =>
      'In the test data, changes last until the app restarts.';

  @override
  String get entry_new => 'New entry';

  @override
  String get entry_edit => 'Edit entry';

  @override
  String get entry_category => 'Category';

  @override
  String get entry_title => 'Title';

  @override
  String get entry_body => 'Text';

  @override
  String get entry_has_date => 'With date';

  @override
  String get entry_date => 'Date';

  @override
  String get entry_time => 'Time';

  @override
  String get entry_notify => 'Notify members';

  @override
  String get entry_notify_hint =>
      'Push notification once the cloud is built in.';

  @override
  String get entry_delete_confirm => 'Delete entry?';

  @override
  String get entry_required => 'Please fill in.';

  @override
  String get mosque_contact => 'Contact';

  @override
  String get mosque_edit_about => 'Description';

  @override
  String get mosque_edit_friday => 'Friday prayer';

  @override
  String get mosque_edit_phone => 'Phone';

  @override
  String get mosque_edit_website => 'Website';

  @override
  String get mosque_edit_none => 'Not set';

  @override
  String get mosque_edit_locked =>
      'Name, address and badges are changed by the app team.';

  @override
  String get category_new => 'New category';

  @override
  String get category_edit => 'Edit category';

  @override
  String get category_name => 'Name';

  @override
  String get category_color => 'Colour';

  @override
  String get category_icon => 'Icon';

  @override
  String get category_builtin => 'Standard';

  @override
  String get category_custom_hint =>
      'Standard categories exist everywhere. Your own apply only to your mosque.';

  @override
  String get category_delete_confirm =>
      'Entries in this category become “Event”.';

  @override
  String get team_invite => 'Invite';

  @override
  String get team_invite_title => 'Invite code';

  @override
  String get team_invite_message =>
      'Pass this code on. It works once and for 7 days.';

  @override
  String get team_you => 'You';

  @override
  String get team_roles_hint =>
      'Owner: everything, including the team. Admin: page, events, categories. Editor: events and announcements only.';

  @override
  String get team_remove => 'Remove';

  @override
  String get common_copy => 'Copy';

  @override
  String get category_own => 'Your own';

  @override
  String get qibla_based_on_location => 'Calculated for your location';
}
