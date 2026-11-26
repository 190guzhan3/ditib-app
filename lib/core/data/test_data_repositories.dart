import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:moschee_app/core/data/community_repository.dart';
import 'package:moschee_app/core/data/mosque_repository.dart';
import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque_badge.dart';
import 'package:moschee_app/core/models/team_member.dart';
import 'package:moschee_app/core/models/community_post.dart';
import 'package:moschee_app/core/models/mosque.dart';

/// Testdaten aus `assets/testdata/test_data.json` (erzeugt mit
/// `tool/build_test_data.py`). Zeiten sind relativ zum Ladezeitpunkt.
class TestDataFile {
  TestDataFile._();

  static const path = 'assets/testdata/test_data.json';
  static Map<String, dynamic>? _cache;

  static Future<Map<String, dynamic>> read() async => _cache ??=
      json.decode(await rootBundle.loadString(path)) as Map<String, dynamic>;
}

/// Moscheen aus den Testdaten. Änderungen der Verwaltung bleiben bis zum
/// Neustart der App im Speicher.
class TestMosqueRepository implements MosqueRepository {
  MosqueData? _data;
  final Map<String, List<TeamMember>> _teams = {};

  @override
  Future<MosqueData> load() async {
    if (_data != null) return _data!;
    final data = await TestDataFile.read();
    final now = DateTime.now();
    List<Map<String, dynamic>> list(String key) =>
        (data[key] as List? ?? const []).cast<Map<String, dynamic>>();
    return _data = MosqueData(
      regions: list('regions').map(MosqueRegion.fromJson).toList(),
      badges: list('badges').map(MosqueBadge.fromJson).toList(),
      mosques: list('mosques').map(Mosque.fromJson).toList(),
      categories: list('categories').map(EventCategory.fromJson).toList(),
      announcements: [
        for (final a in list('announcements'))
          Announcement.fromTestJson(a, now),
      ],
      defaultMyMosques: (data['defaultMyMosques'] as List? ?? const [])
          .cast<String>(),
    );
  }

  /// Ersetzt im Speicher die Liste, in der [id] vorkommt.
  MosqueData _with({
    List<Mosque>? mosques,
    List<EventCategory>? categories,
    List<Announcement>? announcements,
  }) {
    final d = _data!;
    return _data = MosqueData(
      regions: d.regions,
      badges: d.badges,
      mosques: mosques ?? d.mosques,
      categories: categories ?? d.categories,
      announcements: announcements ?? d.announcements,
      defaultMyMosques: d.defaultMyMosques,
    );
  }

  static List<T> _upsert<T>(List<T> list, T item, String Function(T) id) {
    final i = list.indexWhere((e) => id(e) == id(item));
    return i < 0 ? [...list, item] : ([...list]..[i] = item);
  }

  @override
  Future<void> saveMosque(Mosque mosque) async {
    await load();
    _with(mosques: _upsert(_data!.mosques, mosque, (m) => m.id));
  }

  @override
  Future<void> saveAnnouncement(Announcement a) async {
    await load();
    _with(announcements: _upsert(_data!.announcements, a, (e) => e.id));
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await load();
    _with(
      announcements: _data!.announcements.where((a) => a.id != id).toList(),
    );
  }

  @override
  Future<void> saveCategory(EventCategory category) async {
    await load();
    _with(categories: _upsert(_data!.categories, category, (c) => c.id));
  }

  /// Einträge der gelöschten Kategorie werden zu „Veranstaltung“.
  @override
  Future<void> deleteCategory(String id) async {
    await load();
    _with(
      categories: _data!.categories.where((c) => c.id != id).toList(),
      announcements: [
        for (final a in _data!.announcements)
          a.categoryId == id ? a.copyWith(categoryId: EventCategory.event) : a,
      ],
    );
  }

  @override
  Future<List<TeamMember>> loadTeam(String mosqueId) async =>
      _teams[mosqueId] ??= const [
        TeamMember(id: 'me', name: '', role: MosqueRole.owner, isMe: true),
        TeamMember(id: 't1', name: 'Elif', role: MosqueRole.admin),
        TeamMember(id: 't2', name: 'Mehmet', role: MosqueRole.editor),
      ];

  @override
  Future<void> saveTeamMember(String mosqueId, TeamMember member) async {
    _teams[mosqueId] = _upsert(await loadTeam(mosqueId), member, (m) => m.id);
  }

  @override
  Future<void> removeTeamMember(String mosqueId, String memberId) async {
    _teams[mosqueId] = (await loadTeam(
      mosqueId,
    )).where((m) => m.id != memberId).toList();
  }
}

/// Community-Beiträge aus den Testdaten. Neue Beiträge und gemeldetes
/// Interesse bleiben nur bis zum Neustart.
class TestCommunityRepository implements CommunityRepository {
  final List<CommunityPost> _created = [];
  final Set<String> _interested = {};

  @override
  Future<List<CommunityPost>> load() async {
    final data = await TestDataFile.read();
    final now = DateTime.now();
    final posts = [
      ..._created,
      for (final p in (data['communityPosts'] as List))
        CommunityPost.fromTestJson(p as Map<String, dynamic>, now),
    ];
    return [
      for (final p in posts)
        _interested.contains(p.id)
            ? p.copyWith(interestCount: p.interestCount + 1, myInterest: true)
            : p,
    ];
  }

  @override
  Future<void> create(CommunityPost post) async => _created.insert(0, post);

  @override
  Future<void> setInterest(String postId, bool interested) async {
    interested ? _interested.add(postId) : _interested.remove(postId);
  }
}
