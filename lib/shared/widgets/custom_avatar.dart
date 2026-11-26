import 'package:flutter/material.dart';
import 'package:moschee_app/core/services/image_store.dart';

class CustomAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomAvatar({
    super.key,
    required this.imagePath,
    this.radius = 24,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
  });

  bool get _hasImagePath => imagePath != null && imagePath!.isNotEmpty;
  bool get _isNetworkImage => _hasImagePath && imagePath!.startsWith('http');
  bool get _isAssetImage => _hasImagePath && imagePath!.startsWith('assets/');
  bool get _isLocalFileImage =>
      _hasImagePath && !_isNetworkImage && !_isAssetImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nutze die übergebene Farbe oder falle auf den Standard zurück
    final finalBgColor =
        backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.12);
    final finalIconColor = iconColor ?? theme.colorScheme.primary;

    if (_isAssetImage) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: finalBgColor,
        child: ClipOval(
          child: Image.asset(
            imagePath!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallbackIcon(
              backgroundColor: finalBgColor,
              iconColor: finalIconColor,
            ),
          ),
        ),
      );
    }

    // Nur so groß dekodieren, wie angezeigt wird (spart Speicher).
    final imageProvider = _isNetworkImage || _isLocalFileImage
        ? ImageStore.provider(
            imagePath,
            decodeWidth: (radius * 2 * MediaQuery.devicePixelRatioOf(context))
                .round(),
          )
        : null;

    if (imageProvider == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: finalBgColor,
        child: Icon(fallbackIcon, color: finalIconColor, size: radius * 1.1),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: finalBgColor,
      child: ClipOval(
        child: Image(
          image: imageProvider,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          // Bei einem neuen Bild (z. B. geändertes Logo) das alte zeigen,
          // bis das neue geladen ist, statt kurz nur die Hintergrundfarbe.
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _buildFallbackIcon(
            backgroundColor: finalBgColor,
            iconColor: finalIconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon({
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: Icon(fallbackIcon, color: iconColor, size: radius * 1.1),
      ),
    );
  }
}
