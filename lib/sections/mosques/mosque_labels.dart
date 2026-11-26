import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/models/team_member.dart';
import 'package:moschee_app/core/services/prayer_times.dart';
import 'package:moschee_app/core/theme/theme.dart';

/// Texte, Farben und Icons zu Moschee-Daten, an einer Stelle.
extension MosqueLabels on AppLocalizations {
  String association(Mosque m) => switch (m.association) {
    'ditib' => association_ditib,
    'igmg' => association_igmg,
    'vikz' => association_vikz,
    'zmd' => association_zmd,
    _ => association_independent,
  };

  String associationInfo(Mosque m) => switch (m.association) {
    'ditib' => association_info_ditib,
    _ => association_info_other,
  };

  /// Name der Kategorie: Standard aus l10n, eigene aus den Daten.
  String categoryName(EventCategory c) => switch (c.id) {
    EventCategory.info => kind_info,
    EventCategory.event => kind_event,
    EventCategory.cenaze => kind_cenaze,
    EventCategory.course => kind_course,
    EventCategory.festival => kind_festival,
    EventCategory.youth => kind_youth,
    _ => c.name ?? kind_event,
  };

  String role(MosqueRole r) => switch (r) {
    MosqueRole.owner => admin_role_owner,
    MosqueRole.admin => admin_role_admin,
    MosqueRole.editor => admin_role_editor,
  };

  String prayer(PrayerSlot s) => switch (s) {
    PrayerSlot.fajr => prayer_fajr,
    PrayerSlot.sunrise => prayer_sunrise,
    PrayerSlot.dhuhr => prayer_dhuhr,
    PrayerSlot.asr => prayer_asr,
    PrayerSlot.maghrib => prayer_maghrib,
    PrayerSlot.isha => prayer_isha,
  };

  String prayerMethod(PrayerMethod m) => switch (m) {
    PrayerMethod.diyanet => prayer_method_diyanet,
    PrayerMethod.muslimWorldLeague => prayer_method_muslimWorldLeague,
    PrayerMethod.northAmerica => prayer_method_northAmerica,
  };
}

/// Farbe der Kategorie: Standard aus dem Theme, eigene aus den Daten.
Color categoryColor(EventCategory c) => switch (c.id) {
  EventCategory.info => AppColors.kindInfo,
  EventCategory.event => AppColors.kindEvent,
  EventCategory.cenaze => AppColors.kindCenaze,
  EventCategory.course => AppColors.kindCourse,
  EventCategory.festival => AppColors.kindFestival,
  EventCategory.youth => AppColors.kindYouth,
  _ => Color(c.colorValue),
};

/// Symbole, aus denen Kategorien wählen (Schlüssel bleibt in den Daten).
const categoryIcons = <String, IconData>{
  'info': Icons.campaign_outlined,
  'event': Icons.event_outlined,
  'cenaze': Icons.local_florist_outlined,
  'course': Icons.menu_book_outlined,
  'festival': Icons.celebration_outlined,
  'youth': Icons.groups_outlined,
  'women': Icons.woman_outlined,
  'family': Icons.family_restroom_outlined,
  'children': Icons.child_care_outlined,
  'sport': Icons.sports_soccer_outlined,
  'food': Icons.restaurant_outlined,
  'charity': Icons.volunteer_activism_outlined,
  'prayer': Icons.mosque_outlined,
  'talk': Icons.record_voice_over_outlined,
  'trip': Icons.directions_bus_outlined,
  'quran': Icons.auto_stories_outlined,
};

IconData categoryIcon(EventCategory c) =>
    categoryIcons[c.icon] ?? Icons.event_outlined;

/// Symbole der Siegel (Schlüssel aus den Daten).
const badgeIcons = <String, IconData>{
  'verified': Icons.verified,
  'accessible': Icons.accessible_rounded,
  'women': Icons.woman_rounded,
  'parking': Icons.local_parking_rounded,
};

IconData badgeIcon(String key) => badgeIcons[key] ?? Icons.label_outline;

Color regionColor(MosqueRegion? r, ThemeData theme) =>
    r == null ? theme.colorScheme.primary : Color(r.colorValue);
