import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/community_post.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/community/community_labels.dart';
import 'package:moschee_app/shared/widgets/sliding_segments.dart';
import 'package:uuid/uuid.dart';

/// Neuer Beitrag: Biete/Suche, Kategorie, Titel, Text, Gemeinde.
Future<void> showPostForm(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => const _PostForm(),
);

class _PostForm extends StatefulWidget {
  const _PostForm();

  @override
  State<_PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<_PostForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  PostKind _kind = PostKind.offer;
  PostCategory _category = PostCategory.education;
  String? _mosqueId = DataRepository.instance.primaryMosque?.id;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_form.currentState!.validate()) return;
    final t = AppLocalizations.of(context)!;
    final data = DataRepository.instance;
    final mosqueId = _mosqueId ?? data.mosques.first.id;
    await data.createPost(
      CommunityPost(
        id: const Uuid().v4(),
        kind: _kind,
        category: _category,
        title: _title.text.trim(),
        body: _body.text.trim(),
        authorName: AccountService.instance.user?.name ?? '',
        mosqueId: mosqueId,
        postedAt: DateTime.now(),
        mine: true,
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(t.post_created)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    final choices = data.myMosques.isEmpty ? data.mosques : data.myMosques;
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? t.post_form_required : null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.post_new_title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                SlidingSegments<PostKind>(
                  options: [
                    (value: PostKind.offer, label: t.post_offer, icon: null),
                    (
                      value: PostKind.request,
                      label: t.post_request,
                      icon: null,
                    ),
                  ],
                  value: _kind,
                  onChanged: (v) => setState(() => _kind = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PostCategory>(
                  initialValue: _category,
                  decoration: AppFormStyles.decoration(
                    context,
                    labelText: t.post_form_category,
                  ),
                  items: [
                    for (final c in PostCategory.values)
                      DropdownMenuItem(value: c, child: Text(t.category(c))),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  maxLength: 80,
                  decoration: AppFormStyles.decoration(
                    context,
                    labelText: t.post_form_title,
                  ),
                  validator: required,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _body,
                  maxLength: 600,
                  minLines: 3,
                  maxLines: 6,
                  decoration: AppFormStyles.decoration(
                    context,
                    labelText: t.post_form_body,
                  ),
                  validator: required,
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _mosqueId,
                  decoration: AppFormStyles.decoration(
                    context,
                    labelText: t.post_form_mosque,
                  ),
                  items: [
                    for (final m in choices)
                      DropdownMenuItem(value: m.id, child: Text(m.name)),
                  ],
                  onChanged: (v) => setState(() => _mosqueId = v),
                ),
                const SizedBox(height: 12),
                Text(t.post_form_rules, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _publish,
                  child: Text(t.post_form_publish),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
