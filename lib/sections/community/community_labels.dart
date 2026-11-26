import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/community_post.dart';
import 'package:moschee_app/core/theme/theme.dart';

extension CommunityLabels on AppLocalizations {
  String category(PostCategory c) => switch (c) {
    PostCategory.education => category_education,
    PostCategory.children => category_children,
    PostCategory.moving => category_moving,
    PostCategory.transport => category_transport,
    PostCategory.repair => category_repair,
    PostCategory.accompany => category_accompany,
    PostCategory.giveaway => category_giveaway,
    PostCategory.other => category_other,
  };

  String postKind(PostKind k) =>
      k == PostKind.offer ? post_offer : post_request;
}

IconData categoryIcon(PostCategory c) => switch (c) {
  PostCategory.education => Icons.school_outlined,
  PostCategory.children => Icons.child_care_outlined,
  PostCategory.moving => Icons.local_shipping_outlined,
  PostCategory.transport => Icons.directions_car_outlined,
  PostCategory.repair => Icons.build_outlined,
  PostCategory.accompany => Icons.handshake_outlined,
  PostCategory.giveaway => Icons.redeem_outlined,
  PostCategory.other => Icons.more_horiz,
};

Color postKindColor(PostKind k) =>
    k == PostKind.offer ? AppColors.offer : AppColors.request;
