import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/auth/auth_screen.dart';

/// Konto in den Einstellungen (wie im TeamManager): abgemeldet ein Hinweis
/// zum Anmelden, angemeldet Name, E-Mail und das Drei-Punkte-Menü.
class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final account = AccountService.instance;
    return ListenableBuilder(
      listenable: account,
      builder: (context, _) {
        final user = account.user;
        final accent = theme.colorScheme.primary;
        return InkWell(
          onTap: user == null ? () => openAuth(context) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: user != null
                      ? accent.withValues(alpha: 0.14)
                      : theme.dividerColor.withValues(alpha: 0.18),
                  child: user != null
                      ? Text(
                          user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                          style: AppTypography.titleMedium.copyWith(
                            color: accent,
                          ),
                        )
                      : Icon(AppIcons.login, color: theme.disabledColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? t.account_sign_in,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? t.account_sign_in_hint,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user != null && account.isTestAccount) ...[
                        const SizedBox(height: 2),
                        Text(
                          t.account_test,
                          style: AppTypography.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (user != null)
                  IconButton(
                    icon: const Icon(AppIcons.more),
                    onPressed: () => _showActions(context),
                  )
                else
                  Icon(AppIcons.chevron, color: theme.disabledColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(t.account_change_name),
              onTap: () => Navigator.pop(sheetContext, 'name'),
            ),
            ListTile(
              leading: const Icon(Icons.alternate_email),
              title: Text(t.account_change_email),
              onTap: () => Navigator.pop(sheetContext, 'email'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: Text(t.account_change_password),
              onTap: () => Navigator.pop(sheetContext, 'password'),
            ),
            ListTile(
              leading: const Icon(AppIcons.logout),
              title: Text(t.account_sign_out),
              onTap: () => Navigator.pop(sheetContext, 'logout'),
            ),
            ListTile(
              leading: const Icon(AppIcons.delete, color: AppColors.error),
              title: Text(
                t.account_delete,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    final account = AccountService.instance;
    switch (selected) {
      case 'name':
        await _changeName(context);
      case 'logout':
        await account.signOut();
      case 'delete':
        final ok = await showAppConfirmDialog(
          context,
          title: t.account_delete,
          message: '${t.account_delete_confirm} ${t.common_irreversible}',
          confirmLabel: t.common_delete,
          cancelLabel: t.common_cancel,
          destructive: true,
        );
        if (ok) await account.deleteAccount();
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.account_not_in_test)));
    }
  }

  Future<void> _changeName(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: AccountService.instance.user?.name,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.account_change_name),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: AppFormStyles.decoration(
            dialogContext,
            labelText: t.auth_name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(t.common_save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      await AccountService.instance.updateName(name.trim());
    }
  }
}
