import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/image_store.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/shared/widgets/custom_avatar.dart';

/// Rundes Bild (Teamlogo, Spieler) mit einheitlicher Bedienung:
/// - mit Bearbeitungsrecht: Stift unten rechts; Tippen öffnet ein Menü mit
///   „Ansehen“, „Bild ändern“ und „Entfernen“,
/// - ohne: Tippen öffnet das Bild groß ([showImageViewer]).
class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.imagePath,
    this.radius = 30,
    this.fallbackIcon = Icons.person,
    this.canEdit = false,
    this.onPick,
    this.onRemove,
    this.viewerTitle,
  });

  final String? imagePath;
  final double radius;
  final IconData fallbackIcon;
  final bool canEdit;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  /// Überschrift in der Großansicht (z. B. Team- oder Spielername).
  final String? viewerTitle;

  bool get _hasImage => imagePath?.isNotEmpty == true;

  Future<void> _onTap(BuildContext context) async {
    if (!canEdit) {
      if (_hasImage) {
        await showImageViewer(context, imagePath!, title: viewerTitle);
      }
      return;
    }
    // Ohne Bild gibt es nichts anzusehen oder zu entfernen.
    if (!_hasImage) {
      onPick?.call();
      return;
    }
    final t = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.zoom_in_rounded),
              title: Text(t.image_view),
              onTap: () => Navigator.pop(sheetContext, 'view'),
            ),
            if (onPick != null)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(t.image_change),
                onTap: () => Navigator.pop(sheetContext, 'pick'),
              ),
            if (onRemove != null)
              ListTile(
                leading: Icon(AppIcons.delete, color: AppColors.error),
                title: Text(
                  t.image_remove,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(sheetContext, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'view':
        await showImageViewer(context, imagePath!, title: viewerTitle);
      case 'pick':
        onPick?.call();
      case 'remove':
        onRemove?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = CustomAvatar(
      imagePath: imagePath,
      radius: radius,
      fallbackIcon: fallbackIcon,
    );
    final tappable = canEdit || _hasImage;
    final t = AppLocalizations.of(context)!;
    final label = canEdit
        ? (_hasImage ? t.image_change : t.image_choose)
        : (_hasImage ? t.image_view : null);
    return Semantics(
      button: tappable,
      image: true,
      label: [?viewerTitle, ?label].join(', '),
      child: GestureDetector(
        onTap: tappable ? () => _onTap(context) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatar,
            if (canEdit)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: EdgeInsets.all(radius >= 40 ? 7 : 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    AppIcons.edit,
                    size: radius >= 40 ? 16 : 12,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Zeigt ein Bild bildschirmfüllend mit Zoom (zwei Finger / Doppeltippen).
Future<void> showImageViewer(
  BuildContext context,
  String imagePath, {
  String? title,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) =>
          _ImageViewer(imagePath: imagePath, title: title),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.imagePath, this.title});

  final String imagePath;
  final String? title;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final _controller = TransformationController();

  ImageProvider get _provider => ImageStore.provider(widget.imagePath)!;

  void _toggleZoom(TapDownDetails details) {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
      return;
    }
    final position = details.localPosition;
    _controller.value = Matrix4.identity()
      ..translateByDouble(-position.dx, -position.dy, 0, 1)
      ..scaleByDouble(2, 2, 1, 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.title == null ? null : Text(widget.title!),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: _toggleZoom,
        onDoubleTap: () {},
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1,
          maxScale: 5,
          child: SizedBox.expand(
            child: Image(
              image: _provider,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
