import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/shared/format.dart';
import 'package:moschee_app/shared/widgets/section_title.dart';
import 'package:moschee_app/shared/widgets/settings_tiles.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';
import 'package:uuid/uuid.dart';

/// Termin oder Ankündigung anlegen bzw. bearbeiten.
Future<void> openEntryEditor(
  BuildContext context,
  Mosque mosque, {
  Announcement? entry,
}) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => EntryEditScreen(mosque: mosque, entry: entry),
  ),
);

class EntryEditScreen extends StatefulWidget {
  const EntryEditScreen({super.key, required this.mosque, this.entry});

  final Mosque mosque;
  final Announcement? entry;

  @override
  State<EntryEditScreen> createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.entry?.title);
  late final _body = TextEditingController(text: widget.entry?.body);
  late String _category = widget.entry?.categoryId ?? EventCategory.event;
  late bool _hasDate = widget.entry == null || widget.entry!.start != null;
  late DateTime _start = widget.entry?.start ?? _defaultStart();
  bool _notify = true;

  static DateTime _defaultStart() {
    final d = DateTime.now().add(const Duration(days: 1));
    return DateTime(d.year, d.month, d.day, 19);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _pickCategory(String id) => setState(() {
    // Hinweise haben meist keinen Termin, alles andere schon.
    if (id == EventCategory.info) _hasDate = false;
    if (_category == EventCategory.info && id != EventCategory.info) {
      _hasDate = true;
    }
    _category = id;
  });

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (d != null) {
      setState(
        () => _start = DateTime(
          d.year,
          d.month,
          d.day,
          _start.hour,
          _start.minute,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time != null) {
      setState(
        () => _start = DateTime(
          _start.year,
          _start.month,
          _start.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final t = AppLocalizations.of(context)!;
    final old = widget.entry;
    final entry = Announcement(
      id: old?.id ?? const Uuid().v4(),
      mosqueId: widget.mosque.id,
      categoryId: _category,
      title: _title.text.trim(),
      body: _body.text.trim(),
      postedAt: old?.postedAt ?? DateTime.now(),
      start: _hasDate ? _start : null,
    );
    // Push („_notify“) kommt mit der Cloud (Cloud Function beim Anlegen).
    await DataRepository.instance.saveAnnouncement(entry);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(t.common_saved)));
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context)!;
    final ok = await showAppConfirmDialog(
      context,
      title: t.entry_delete_confirm,
      message: t.common_irreversible,
      confirmLabel: t.common_delete,
      cancelLabel: t.common_cancel,
      destructive: true,
    );
    if (!ok) return;
    await DataRepository.instance.deleteAnnouncement(widget.entry!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categories = DataRepository.instance.categoriesFor(widget.mosque.id);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? t.entry_required : null;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        actions: [AppSaveButton(onPressed: _save)],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            SectionTitle(t.entry_category),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  ChoiceChip(
                    avatar: Icon(
                      categoryIcon(c),
                      size: 16,
                      color: categoryColor(c),
                    ),
                    label: Text(t.categoryName(c)),
                    selected: _category == c.id,
                    selectedColor: categoryColor(c).withValues(alpha: 0.2),
                    side: _category == c.id
                        ? BorderSide(color: categoryColor(c))
                        : null,
                    onSelected: (_) => _pickCategory(c.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: AppFormStyles.decoration(
                context,
                labelText: t.entry_title,
              ),
              validator: required,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _body,
              minLines: 4,
              maxLines: 10,
              maxLength: 1500,
              textCapitalization: TextCapitalization.sentences,
              decoration: AppFormStyles.decoration(
                context,
                labelText: t.entry_body,
              ),
            ),
            const SizedBox(height: 8),
            WidgetContainer(
              padding: WidgetContainer.settingsPadding,
              child: SettingsGroup(
                children: [
                  SettingsSwitchTile(
                    leading: const Icon(AppIcons.calendar),
                    title: t.entry_has_date,
                    value: _hasDate,
                    onChanged: (v) => setState(() => _hasDate = v),
                  ),
                  if (_hasDate) ...[
                    SettingsTile(
                      title: t.entry_date,
                      trailing: Text(
                        Format.day(context, _start),
                        style: SettingsTextStyles.value(context),
                      ),
                      onTap: _pickDate,
                    ),
                    SettingsTile(
                      title: t.entry_time,
                      trailing: Text(
                        Format.time(context, _start),
                        style: SettingsTextStyles.value(context),
                      ),
                      onTap: _pickTime,
                    ),
                  ],
                  SettingsSwitchTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: t.entry_notify,
                    subtitle: t.entry_notify_hint,
                    value: _notify,
                    onChanged: (v) => setState(() => _notify = v),
                  ),
                ],
              ),
            ),
            if (widget.entry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(AppIcons.delete),
                label: Text(t.common_delete),
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
