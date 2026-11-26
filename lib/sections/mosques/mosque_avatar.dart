import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/shared/widgets/custom_avatar.dart';

/// Profilbild einer Moschee; ohne eigenes Bild ein Moschee-Symbol in der
/// Farbe ihrer Region.
class MosqueAvatar extends StatelessWidget {
  const MosqueAvatar({super.key, required this.mosque, this.radius = 24});

  final Mosque mosque;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = regionColor(
      DataRepository.instance.region(mosque.region),
      Theme.of(context),
    );
    return CustomAvatar(
      imagePath: mosque.imagePath,
      radius: radius,
      fallbackIcon: AppIcons.mosque,
      backgroundColor: color.withValues(alpha: 0.16),
      iconColor: color,
    );
  }
}
