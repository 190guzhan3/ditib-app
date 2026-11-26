import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moschee_app/core/theme/app_design.dart';

/// Eine Aktion hinter einem [SwipeActionTile].
class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
}

/// Listeneintrag mit Wisch-Aktionen links und/oder rechts.
///
/// Die Aktionen wachsen beim Aufziehen nacheinander herein, die Zeile wird
/// dabei leicht abgedunkelt. Einträge mit gleichem [groupTag] schließen
/// sich gegenseitig (nur eine Zeile offen). Die Liste dafür in
/// `SlidableAutoCloseBehavior` einbetten.
class SwipeActionTile extends StatelessWidget {
  const SwipeActionTile({
    super.key,
    required this.child,
    this.startActions = const [],
    this.endActions = const [],
    this.groupTag = 'swipe-actions',
    this.highlighted = false,
    this.enabled = true,
  });

  final Widget child;
  final List<SwipeAction> startActions;
  final List<SwipeAction> endActions;
  final Object groupTag;

  /// Dezent in der Akzentfarbe hinterlegt (z. B. eigener Eintrag).
  final bool highlighted;
  final bool enabled;

  /// Breite der Aktionsleiste je Aktion (Anteil der Zeilenbreite).
  static const _ratioPerAction = 0.22;

  /// … aber höchstens so breit wie auf einem großen Handy. Sonst bräuchte
  /// es in breiten Fenstern (Mac) sehr lange Wischwege.
  static const _maxPerAction = 96.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, box) => _slidable(theme, box.maxWidth),
    );
  }

  Widget _slidable(ThemeData theme, double width) {
    return Slidable(
      key: key,
      groupTag: groupTag,
      enabled: enabled,
      startActionPane: _pane(startActions, Alignment.centerLeft, width),
      endActionPane: _pane(endActions, Alignment.centerRight, width),
      child: Builder(
        builder: (context) {
          final controller = Slidable.of(context)!;
          return AnimatedBuilder(
            animation: controller.animation,
            builder: (context, child) => Material(
              color: Color.alphaBlend(
                theme.colorScheme.onSurface.withValues(
                  alpha: 0.14 * controller.animation.value,
                ),
                highlighted
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
              ),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            ),
            child: child,
          );
        },
      ),
    );
  }

  ActionPane? _pane(
    List<SwipeAction> actions,
    Alignment alignment,
    double width,
  ) {
    if (actions.isEmpty) return null;
    var perAction = _ratioPerAction;
    if (width.isFinite && width > 0) {
      perAction = perAction.clamp(0.0, _maxPerAction / width);
    }
    final ratio = (perAction * actions.length).clamp(0.1, 0.8);
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: ratio,
      children: [
        // Eine gemeinsame Fläche, damit die Buttons frei gestaltet werden
        // können (Pillen statt vollflächiger Blöcke). Bewusst kein Button
        // (wie CustomSlidableAction): Die Fläche selbst reagiert weder auf
        // Hover noch auf langes Drücken – nur die Pillen.
        Expanded(
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _SwipeActionButton(
                      action: actions[i],
                      // Reihenfolge des Hereinwachsens: von innen nach außen.
                      step: i / actions.length,
                      ratio: ratio,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.action,
    required this.step,
    required this.ratio,
  });

  final SwipeAction action;
  final double step;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final controller = Slidable.of(context);
    final enabled = action.onPressed != null;
    final button = GestureDetector(
      onTap: enabled
          ? () {
              controller?.close();
              action.onPressed!();
            }
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 32,
            decoration: BoxDecoration(
              color: enabled ? action.color : Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(action.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 64,
            // Nie abschneiden: lange Wörter werden eher etwas kleiner.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (controller == null) return button;
    // Erst wachsen, wenn der Button großteils freiliegt; ganz groß kurz vor
    // dem vollen Öffnen.
    final start = 0.3 + step * 0.4;
    final end = (start + 0.4).clamp(0.0, 0.98);
    return AnimatedBuilder(
      animation: controller.animation,
      child: button,
      builder: (context, child) {
        final opened = (controller.animation.value.abs() / ratio).clamp(
          0.0,
          1.0,
        );
        final progress = ((opened - start) / (end - start)).clamp(0.0, 1.0);
        return Opacity(
          opacity: progress,
          child: Transform.scale(
            scale: Curves.easeOutBack.transform(progress),
            child: child,
          ),
        );
      },
    );
  }
}
