import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/app_design.dart';

/// "Mit Apple anmelden" nach Apples Gestaltungsregeln: schwarz im hellen,
/// weiß im dunklen Design, mit Apple-Logo.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Nur auf Apple-Geräten; dort ist die Anmeldung ohne Zusatzeinrichtung
  /// möglich.
  static bool get isAvailable =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? Colors.white : Colors.black;
    final foreground = isDark ? Colors.black : Colors.white;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, color: foreground, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
