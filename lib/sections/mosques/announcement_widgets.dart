import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_detail_screen.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/shared/format.dart';

/// Kleines farbiges Etikett für die Kategorie (Cenaze, Kurs, Fest …).
class CategoryBadge extends StatelessWidget {
  const CategoryBadge(this.categoryId, {super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final category = DataRepository.instance.category(categoryId);
    final color = categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryIcon(category), size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            t.categoryName(category),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Datumskachel: Wochentag, Tag, Monat – in der Farbe der Art.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.color});

  final DateTime date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            Format.weekdayShort(context, date),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${date.day}',
            style: AppTypography.headline.copyWith(color: color, height: 1.1),
          ),
          Text(
            Format.monthShort(context, date),
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Termin in einer Liste. [showMosque] blendet die Moschee ein (Start,
/// Umgebung), auf der Moschee-Seite selbst nicht.
class AnnouncementTile extends StatelessWidget {
  const AnnouncementTile({
    super.key,
    required this.announcement,
    this.showMosque = true,
    this.distance,
    this.onTap,
  });

  final Announcement announcement;
  final bool showMosque;

  /// Statt der Detailansicht (z. B. Bearbeiten in der Verwaltung).
  final VoidCallback? onTap;

  /// Entfernung zur Hauptmoschee (nur in der Umgebung).
  final String? distance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = announcement;
    final mosque = DataRepository.instance.mosque(a.mosqueId);
    final category = DataRepository.instance.category(a.categoryId);
    final color = categoryColor(category);
    final meta = [
      if (a.start != null) Format.time(context, a.start!),
      if (showMosque && mosque != null) mosque.city,
      ?distance,
    ].join(' · ');
    return InkWell(
      onTap: onTap ?? () => showAnnouncementSheet(context, a),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.start != null)
              _DateTile(date: a.start!, color: color)
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon(category), color: color),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(a.categoryId),
                  const SizedBox(height: 4),
                  Text(
                    a.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.start == null ? Format.ago(context, a.postedAt) : meta,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hervorgehobenes Cenaze-Gebet (steht auf der Startseite ganz oben).
class CenazeBanner extends StatelessWidget {
  const CenazeBanner({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = announcement;
    final mosque = DataRepository.instance.mosque(a.mosqueId);
    const color = AppColors.kindCenaze;
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showAnnouncementSheet(context, a),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                categoryIcon(DataRepository.instance.category(a.categoryId)),
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (a.start != null) Format.dayTime(context, a.start!),
                        ?mosque?.name,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(AppIcons.chevron),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ganze Ankündigung als Bottom-Sheet.
Future<void> showAnnouncementSheet(BuildContext context, Announcement a) {
  final t = AppLocalizations.of(context)!;
  final mosque = DataRepository.instance.mosque(a.mosqueId);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: SingleChildScrollView(
            primary: false,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryBadge(a.categoryId),
                const SizedBox(height: 10),
                Text(a.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (a.start != null)
                  _InfoRow(
                    icon: AppIcons.time,
                    text: Format.dayTime(sheetContext, a.start!),
                  ),
                if (mosque != null)
                  _InfoRow(
                    icon: AppIcons.place,
                    text: '${mosque.name}, ${mosque.postalCode} ${mosque.city}',
                  ),
                const SizedBox(height: 8),
                Text(
                  a.body,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 8),
                Text(
                  Format.ago(sheetContext, a.postedAt),
                  style: theme.textTheme.bodySmall,
                ),
                if (mosque != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(AppIcons.mosque),
                      label: Text(t.announcement_open_mosque),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        openMosque(context, mosque);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
