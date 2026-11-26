import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/theme.dart';

/// Kopf für Detailseiten: großes Bild, darunter der Titel. Beim Scrollen schrumpft und verblasst das Cover; der Titel
/// wandert mit nach oben und bleibt dann in der Kopfleiste "kleben"
/// (ein einziges Element, kein Überblenden).
class CollapsingCoverHeader extends StatelessWidget {
  const CollapsingCoverHeader({
    super.key,
    required this.title,
    required this.cover,
    this.actions,
    this.coverSize = 220,
  });

  final String title;

  /// Baut das Bild in der gewünschten Größe. Bilder darin bitte mit fester
  /// Dekodiergröße (`cacheWidth`/`cacheHeight`), sonst flackern sie beim
  /// Scrollen.
  final Widget Function(double size) cover;
  final List<Widget>? actions;
  final double coverSize;

  static const _titleBlock = 48.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expanded = coverSize + 20 + _titleBlock;
    return SliverAppBar(
      pinned: true,
      expandedHeight: expanded,
      leading: const AppBackButton(),
      actions: actions,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, c) {
          final top = MediaQuery.paddingOf(context).top;
          final toolbar = theme.appBarTheme.toolbarHeight ?? kToolbarHeight;
          final minH = top + toolbar;
          final extra = c.maxHeight - minH;
          // 1 = ganz offen, 0 = eingeklappt.
          final t = (extra / (expanded - toolbar)).clamp(0.0, 1.0);
          // Wie weit der Titel noch von der Kopfleiste entfernt ist (0 = klebt).
          final stick = (extra / _titleBlock).clamp(0.0, 1.0);

          // Titel: unten im Kopf, aber nie höher als die Mitte der Leiste.
          final titleCenter = (c.maxHeight - _titleBlock / 2).clamp(
            top + toolbar / 2,
            double.infinity,
          );
          final side = lerpDouble(64, 24, stick)!;
          final fontSize = lerpDouble(16, 20, stick)!;

          final size = (coverSize * (0.5 + 0.5 * t)).clamp(
            0.0,
            (c.maxHeight - top - _titleBlock - 4).clamp(0.0, coverSize),
          );
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (size > 8)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _titleBlock + 4 * t,
                  child: Center(
                    child: Opacity(
                      // Früh ausblenden, bevor es unter die Leiste rutscht.
                      opacity: Curves.easeIn.transform(
                        ((t - 0.15) / 0.85).clamp(0.0, 1.0),
                      ),
                      child: cover(size),
                    ),
                  ),
                ),
              Positioned(
                left: side,
                right: side,
                top: titleCenter - _titleBlock / 2,
                height: _titleBlock,
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
