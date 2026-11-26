import 'package:moschee_app/core/models/community_post.dart';

/// Datenquelle für die Community (Hilfebörse).
abstract interface class CommunityRepository {
  Future<List<CommunityPost>> load();
  Future<void> create(CommunityPost post);
  Future<void> setInterest(String postId, bool interested);
}
