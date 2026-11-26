import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/models/mosque_badge.dart';
import 'package:moschee_app/core/models/team_member.dart';

/// Alles Öffentliche über Moscheen: Regionen, Siegel, Moschee-Seiten, eigene
/// Kategorien und Ankündigungen/Termine.
class MosqueData {
  const MosqueData({
    required this.regions,
    required this.badges,
    required this.mosques,
    required this.categories,
    required this.announcements,
    this.defaultMyMosques = const [],
  });

  final List<MosqueRegion> regions;
  final List<MosqueBadge> badges;
  final List<Mosque> mosques;

  /// Nur eigene Kategorien der Moscheen; Standard-Kategorien kommen aus
  /// dem Code.
  final List<EventCategory> categories;
  final List<Announcement> announcements;

  /// Vorauswahl „Meine Moscheen“, solange der Nutzer nichts gewählt hat
  /// (nur Testdaten).
  final List<String> defaultMyMosques;
}

/// Datenquelle für Moscheen. Umsetzungen: [TestMosqueRepository], später
/// Firebase/Supabase. Screens nutzen sie nur über das `DataRepository`.
///
/// Schreiben dürfen nur Verantwortliche der jeweiligen Moschee; das prüft
/// später das Backend (Regeln bzw. Cloud Functions), nicht der Client.
abstract interface class MosqueRepository {
  Future<MosqueData> load();

  Future<void> saveMosque(Mosque mosque);
  Future<void> saveAnnouncement(Announcement announcement);
  Future<void> deleteAnnouncement(String id);
  Future<void> saveCategory(EventCategory category);
  Future<void> deleteCategory(String id);

  Future<List<TeamMember>> loadTeam(String mosqueId);
  Future<void> saveTeamMember(String mosqueId, TeamMember member);
  Future<void> removeTeamMember(String mosqueId, String memberId);
}
