import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/app_design.dart';

/// Shared app-bar navigation for sibling screens with a TabBarView.
class AppScreenTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;

  const AppScreenTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Auf der gefüllten Akzentfarbe wie überall: weiße Schrift.
    final selectedLabelColor = onAccentColor(theme.colorScheme.primary);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08)),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(10),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: selectedLabelColor,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.64,
        ),
        labelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
