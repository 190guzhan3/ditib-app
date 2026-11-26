import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/location_service.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/location_actions.dart';
import 'package:moschee_app/shared/widgets/app_bottom_sheet.dart';

/// Umkreis wählen. Mit [allowOff] gibt es „Aus“ (Karte/Liste ohne
/// Umkreis-Filter). Liefert die Kilometer, 0 für „Aus“, `null` bei Abbruch.
Future<int?> showRadiusSheet(
  BuildContext context, {
  bool allowOff = false,
  bool off = false,
}) {
  final t = AppLocalizations.of(context)!;
  final settings = SettingsService.instance;
  final data = DataRepository.instance;
  return showAppBottomSheet<int>(
    context,
    title: t.radius_title,
    builder: (sheetContext) => ListenableBuilder(
      listenable: Listenable.merge([data, LocationService.instance]),
      builder: (context, _) {
        final origin = data.origin;
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (origin != null)
              Text(
                origin.isDevice
                    ? t.radius_hint_location
                    : t.radius_hint(data.primaryMosque!.name),
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (allowOff)
                  ChoiceChip(
                    label: Text(t.radius_off),
                    selected: off,
                    onSelected: (_) => Navigator.pop(sheetContext, 0),
                  ),
                for (final km in SettingsService.radiusChoices)
                  ChoiceChip(
                    label: Text(t.distance_km('$km')),
                    selected: !off && settings.radiusKm == km,
                    onSelected: (_) {
                      settings.setRadiusKm(km);
                      Navigator.pop(sheetContext, km);
                    },
                  ),
              ],
            ),
            if (!LocationService.instance.enabled) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(AppIcons.myLocation),
                label: Text(t.location_use),
                onPressed: () => enableLocation(sheetContext),
              ),
            ],
          ],
        );
      },
    ),
  );
}
