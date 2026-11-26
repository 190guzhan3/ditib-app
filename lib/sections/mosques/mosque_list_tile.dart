import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_avatar.dart';
import 'package:moschee_app/shared/format.dart';

/// Moschee in Listen: Bild, Name, Ort, Region, Entfernung; Stern für die
/// eigene Auswahl.
class MosqueListTile extends StatelessWidget {
  const MosqueListTile({
    super.key,
    required this.mosque,
    required this.onTap,
    this.trailing,
  });

  final Mosque mosque;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    final distance = data.distanceOf(mosque);
    final mine = data.isMine(mosque.id);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: MosqueAvatar(mosque: mosque, radius: 22),
      title: Text(mosque.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (mosque.region != null) t.region_label(mosque.region!),
          if (data.primaryMosque?.id == mosque.id)
            t.mosque_primary
          else if (distance != null)
            Format.km(context, distance),
        ].join(' · '),
      ),
      trailing:
          trailing ??
          (mine
              ? Icon(AppIcons.star, color: theme.colorScheme.primary)
              : const Icon(AppIcons.chevron)),
    );
  }
}
