import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/services/image_store.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/shared/widgets/editable_avatar.dart';
import 'package:moschee_app/shared/widgets/settings_tiles.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

Future<void> openMosqueEditor(BuildContext context, Mosque mosque) =>
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MosqueEditScreen(mosque: mosque),
      ),
    );

/// Was die Moschee selbst pflegt: Bild, Beschreibung, Freitagsgebet,
/// Kontakt. Name, Adresse und Siegel ändert die App-Leitung.
class MosqueEditScreen extends StatefulWidget {
  const MosqueEditScreen({super.key, required this.mosque});

  final Mosque mosque;

  @override
  State<MosqueEditScreen> createState() => _MosqueEditScreenState();
}

class _MosqueEditScreenState extends State<MosqueEditScreen> {
  late final _about = TextEditingController(text: widget.mosque.about);
  late final _phone = TextEditingController(text: widget.mosque.phone);
  late final _website = TextEditingController(text: widget.mosque.website);
  late String? _image = widget.mosque.imagePath;
  late String? _friday = widget.mosque.fridayPrayer;

  @override
  void dispose() {
    _about.dispose();
    _phone.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final t = AppLocalizations.of(context)!;
    final name = await ImageStore.pick(context, cropTitle: t.image_choose);
    if (name != null) setState(() => _image = name);
  }

  Future<void> _pickFriday() async {
    final parts = (_friday ?? '13:00').split(':');
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (time != null) {
      setState(
        () => _friday =
            '${time.hour.toString().padLeft(2, '0')}:'
            '${time.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    String? text(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    await DataRepository.instance.saveMosque(
      widget.mosque.withPageInfo(
        about: text(_about),
        imagePath: _image,
        fridayPrayer: _friday,
        phone: text(_phone),
        website: text(_website),
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(t.common_saved)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        actions: [AppSaveButton(onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: EditableAvatar(
              imagePath: _image,
              radius: 48,
              fallbackIcon: AppIcons.mosque,
              canEdit: true,
              onPick: _pickImage,
              onRemove: () => setState(() => _image = null),
              viewerTitle: widget.mosque.name,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.mosque.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.lock, size: 14, color: theme.disabledColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  t.mosque_edit_locked,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _about,
            minLines: 3,
            maxLines: 8,
            maxLength: 800,
            textCapitalization: TextCapitalization.sentences,
            decoration: AppFormStyles.decoration(
              context,
              labelText: t.mosque_edit_about,
            ),
          ),
          const SizedBox(height: 8),
          WidgetContainer(
            padding: WidgetContainer.settingsPadding,
            child: SettingsGroup(
              children: [
                SettingsTile(
                  leading: const Icon(AppIcons.mosque),
                  title: t.mosque_edit_friday,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _friday ?? t.mosque_edit_none,
                        style: SettingsTextStyles.value(context),
                      ),
                      if (_friday != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(AppIcons.close, size: 18),
                          onPressed: () => setState(() => _friday = null),
                        ),
                    ],
                  ),
                  onTap: _pickFriday,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: AppFormStyles.decoration(
              context,
              labelText: t.mosque_edit_phone,
              prefixIcon: const Icon(AppIcons.phone),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _website,
            keyboardType: TextInputType.url,
            decoration: AppFormStyles.decoration(
              context,
              labelText: t.mosque_edit_website,
              prefixIcon: const Icon(AppIcons.web),
            ),
          ),
        ],
      ),
    );
  }
}
