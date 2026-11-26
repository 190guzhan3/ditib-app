import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/theme/theme.dart';

/// Anmelden oder registrieren. Liefert `true`, wenn danach angemeldet.
Future<bool> openAuth(BuildContext context, {bool register = false}) async {
  final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AuthScreen(register: register),
    ),
  );
  return ok == true;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.register = false});

  final bool register;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _register = widget.register;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final account = AccountService.instance;
    try {
      if (_register) {
        await account.register(
          _name.text.trim(),
          _email.text.trim(),
          _password.text,
        );
      } else {
        await account.signIn(_email.text.trim(), _password.text);
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                _register ? t.auth_register_title : t.auth_login_title,
                style: AppTypography.display.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 24),
              if (_register) ...[
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: AppFormStyles.decoration(
                    context,
                    labelText: t.auth_name,
                    prefixIcon: const Icon(AppIcons.account),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? t.auth_invalid_name
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: AppFormStyles.decoration(
                  context,
                  labelText: t.auth_email,
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
                validator: (v) => emailPattern.hasMatch(v?.trim() ?? '')
                    ? null
                    : t.auth_invalid_email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofillHints: [
                  _register
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                onFieldSubmitted: (_) => _submit(),
                decoration: AppFormStyles.decoration(
                  context,
                  labelText: t.auth_password,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    (v ?? '').length < 6 ? t.auth_invalid_password : null,
              ),
              if (_register) ...[
                const SizedBox(height: 12),
                Text(t.auth_age_note, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _register
                            ? t.auth_submit_register
                            : t.auth_submit_login,
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _register = !_register),
                child: Text(
                  _register
                      ? t.auth_switch_to_login
                      : t.auth_switch_to_register,
                ),
              ),
              if (AccountService.instance.isTestAccount) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.guideOf(
                      theme.brightness,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 18,
                        color: AppColors.guideOf(theme.brightness),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.auth_test_hint,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
