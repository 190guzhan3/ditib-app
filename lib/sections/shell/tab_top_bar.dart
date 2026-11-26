import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/prayer/qibla_screen.dart';
import 'package:moschee_app/sections/settings/settings_screen.dart';

/// Kopfleiste der Tabs: keine Überschrift; links optional ein Feld (z. B.
/// Suche), rechts Qibla-Kompass und Einstellungen – auf jedem Tab gleich.
class TabTopBar extends StatelessWidget implements PreferredSizeWidget {
  const TabTopBar({super.key, this.leading});

  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: leading,
      actions: [
        AppHeaderIconButton(
          icon: AppIcons.qibla,
          tooltip: t.tooltip_qibla,
          onPressed: () => openQibla(context),
        ),
        AppHeaderIconButton(
          icon: AppIcons.settings,
          tooltip: t.tooltip_settings,
          margin: const EdgeInsets.only(left: 8, right: 12),
          onPressed: () => openSettings(context),
        ),
      ],
    );
  }
}
