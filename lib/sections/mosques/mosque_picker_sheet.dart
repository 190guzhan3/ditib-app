import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_list_tile.dart';
import 'package:moschee_app/shared/fuzzy.dart';

/// Moschee suchen und zur eigenen Auswahl hinzufügen bzw. entfernen.
Future<void> showMosquePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _MosquePicker(),
  );
}

class _MosquePicker extends StatefulWidget {
  const _MosquePicker();

  @override
  State<_MosquePicker> createState() => _MosquePickerState();
}

class _MosquePickerState extends State<_MosquePicker> {
  String _query = '';

  List<Mosque> _results(DataRepository data) {
    if (_query.trim().isEmpty) {
      final list = [...data.mosques];
      // Eigene oben, dann nach Nähe zur Hauptmoschee, sonst nach Name.
      list.sort((a, b) {
        final mine = (data.isMine(b.id) ? 1 : 0) - (data.isMine(a.id) ? 1 : 0);
        if (mine != 0) return mine;
        final da = data.distanceOf(a), db = data.distanceOf(b);
        if (da != null && db != null) return da.compareTo(db);
        return a.name.compareTo(b.name);
      });
      return list;
    }
    final scored = [
      for (final m in data.mosques)
        (m, fuzzyScore(_query, '${m.name} ${m.city} ${m.postalCode}')),
    ].where((e) => e.$2 > 0).toList()..sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final e in scored) e.$1];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: ListenableBuilder(
          listenable: data,
          builder: (context, _) {
            final results = _results(data);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.mosque_picker_title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      AppSaveButton(onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    autofocus: false,
                    decoration: AppFormStyles.decoration(
                      context,
                      hintText: t.mosques_search_hint,
                      prefixIcon: const Icon(AppIcons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    primary: false,
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final m = results[i];
                      final mine = data.isMine(m.id);
                      return MosqueListTile(
                        mosque: m,
                        onTap: () => data.toggleMine(m.id),
                        trailing: Icon(
                          mine ? AppIcons.star : AppIcons.starOutline,
                          color: mine
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
