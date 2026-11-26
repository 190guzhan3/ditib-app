import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/shared/widgets/section_title.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';
import 'package:uuid/uuid.dart';

Future<void> openCategories(BuildContext context, Mosque mosque) =>
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => CategoriesScreen(mosque: mosque)),
    );

/// Kategorien der Moschee: Standard (fest) und eigene (Name, Farbe,
/// Symbol frei wählbar).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.mosque});

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'category-new',
        icon: const Icon(AppIcons.add),
        label: Text(t.category_new),
        onPressed: () => _showEditor(context),
      ),
      body: ListenableBuilder(
        listenable: data,
        builder: (context, _) {
          final all = data.categoriesFor(mosque.id);
          final builtIn = all.where((c) => c.builtIn).toList();
          final custom = all.where((c) => !c.builtIn).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              Text(t.category_custom_hint, style: theme.textTheme.bodySmall),
              if (custom.isNotEmpty) ...[
                SectionTitle(t.category_own),
                WidgetContainer(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final c in custom)
                        _CategoryRow(
                          category: c,
                          onTap: () => _showEditor(context, category: c),
                          trailing: IconButton(
                            icon: const Icon(AppIcons.delete),
                            color: theme.colorScheme.error,
                            onPressed: () => _delete(context, c),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              SectionTitle(t.category_builtin),
              WidgetContainer(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final c in builtIn)
                      _CategoryRow(
                        category: c,
                        trailing: Icon(
                          AppIcons.lock,
                          size: 18,
                          color: theme.disabledColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, EventCategory c) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showAppConfirmDialog(
      context,
      title: '${t.common_delete}: ${t.categoryName(c)}',
      message: t.category_delete_confirm,
      confirmLabel: t.common_delete,
      cancelLabel: t.common_cancel,
      destructive: true,
    );
    if (ok) await DataRepository.instance.deleteCategory(c.id);
  }

  Future<void> _showEditor(BuildContext context, {EventCategory? category}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _CategoryEditor(mosque: mosque, category: category),
      );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, this.trailing, this.onTap});

  final EventCategory category;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = categoryColor(category);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(categoryIcon(category), color: color, size: 20),
      ),
      title: Text(t.categoryName(category)),
      trailing: trailing,
    );
  }
}

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({required this.mosque, this.category});

  final Mosque mosque;
  final EventCategory? category;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final _name = TextEditingController(text: widget.category?.name);
  late int _color =
      widget.category?.colorValue ?? AppColors.categoryChoices.first.toARGB32();
  late String _icon = widget.category?.icon ?? 'event';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final old = widget.category;
    await DataRepository.instance.saveCategory(
      old?.copyWith(name: name, colorValue: _color, icon: _icon) ??
          EventCategory(
            id: '${widget.mosque.id}-${const Uuid().v4().substring(0, 8)}',
            mosqueId: widget.mosque.id,
            name: name,
            colorValue: _color,
            icon: _icon,
          ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = Color(_color);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(categoryIcons[_icon], color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.category == null
                          ? t.category_new
                          : t.category_edit,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  AppSaveButton(onPressed: _save),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                autofocus: widget.category == null,
                maxLength: 30,
                textCapitalization: TextCapitalization.sentences,
                decoration: AppFormStyles.decoration(
                  context,
                  labelText: t.category_name,
                ),
                onChanged: (_) => setState(() {}),
              ),
              SectionTitle(t.category_color),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in AppColors.categoryChoices)
                    GestureDetector(
                      onTap: () => setState(() => _color = c.toARGB32()),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c.toARGB32() == _color
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SectionTitle(t.category_icon),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in categoryIcons.entries)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _icon = e.key),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: e.key == _icon
                              ? color.withValues(alpha: 0.18)
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.05,
                                ),
                          borderRadius: BorderRadius.circular(10),
                          border: e.key == _icon
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          e.value,
                          color: e.key == _icon ? color : null,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
