import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/models/team_member.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

Future<void> openTeam(BuildContext context, Mosque mosque) => Navigator.of(
  context,
  rootNavigator: true,
).push(MaterialPageRoute<void>(builder: (_) => TeamScreen(mosque: mosque)));

/// Verwaltungsteam: Inhaber, Admins, Redakteure. Einladen per einmaligem
/// Code. In der Cloud lösen Einladungen und Rollenwechsel Cloud Functions
/// aus (siehe CLAUDE.md), nie der Client allein.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.mosque});

  final Mosque mosque;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<TeamMember>? _team;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final team = await DataRepository.instance.team(widget.mosque.id);
    if (mounted) setState(() => _team = team);
  }

  Future<void> _setRole(TeamMember m, MosqueRole role) async {
    await DataRepository.instance.saveTeamMember(
      widget.mosque.id,
      m.copyWith(role: role),
    );
    await _load();
  }

  Future<void> _remove(TeamMember m) async {
    await DataRepository.instance.removeTeamMember(widget.mosque.id, m.id);
    await _load();
  }

  Future<void> _invite() {
    final t = AppLocalizations.of(context)!;
    // Vorschau: zufälliger Code. Später erzeugt ihn eine Cloud Function
    // (Einladung mit maxUses: 1, Ablauf nach 7 Tagen).
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    String part() =>
        List.generate(4, (_) => chars[r.nextInt(chars.length)]).join();
    final code = '${part()}-${part()}';
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.team_invite_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              code,
              style: AppTypography.headline.copyWith(letterSpacing: 3),
            ),
            const SizedBox(height: 12),
            Text(t.team_invite_message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.common_close),
          ),
          ElevatedButton.icon(
            icon: const Icon(AppIcons.copy, size: 18),
            label: Text(t.common_copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.common_copied)));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final myName = AccountService.instance.user?.name;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'team-invite',
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(t.team_invite),
        onPressed: _invite,
      ),
      body: _team == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              children: [
                WidgetContainer(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final m in _team!)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.14),
                            child: Text(
                              (m.isMe ? (myName ?? t.team_you) : m.name)[0]
                                  .toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            !m.isMe
                                ? m.name
                                : myName == null
                                ? t.team_you
                                : '$myName (${t.team_you})',
                          ),
                          subtitle: Text(t.role(m.role)),
                          // Den Inhaber (und sich selbst) ändert hier niemand.
                          trailing: m.isMe || m.role == MosqueRole.owner
                              ? null
                              : PopupMenuButton<String>(
                                  icon: const Icon(AppIcons.more),
                                  onSelected: (v) => v == 'remove'
                                      ? _remove(m)
                                      : _setRole(
                                          m,
                                          MosqueRole.values.byName(v),
                                        ),
                                  itemBuilder: (_) => [
                                    for (final r in [
                                      MosqueRole.admin,
                                      MosqueRole.editor,
                                    ])
                                      CheckedPopupMenuItem(
                                        value: r.name,
                                        checked: m.role == r,
                                        child: Text(t.role(r)),
                                      ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text(
                                        t.team_remove,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(t.team_roles_hint, style: theme.textTheme.bodySmall),
              ],
            ),
    );
  }
}
