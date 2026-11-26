import 'dart:convert';

import 'package:moschee_app/core/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Anmeldung. Später Firebase Auth o. Ä. (siehe cloud_template).
abstract interface class AccountRepository {
  Future<AppUser?> restore();
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AppUser> updateName(AppUser user, String name);
  Future<void> signOut();
  Future<void> deleteAccount();
}

/// Testkonto nur auf diesem Gerät: jede gültige Eingabe wird angenommen,
/// das Passwort wird nicht gespeichert.
class TestAccountRepository implements AccountRepository {
  static const _key = 'test_account';

  Future<AppUser> _store(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(user.toJson()));
    return user;
  }

  @override
  Future<AppUser?> restore() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return null;
    return AppUser.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    final name = email.split('@').first;
    return _store(
      AppUser(
        id: 'test-$email',
        name: name.isEmpty ? email : name[0].toUpperCase() + name.substring(1),
        email: email,
      ),
    );
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) => _store(AppUser(id: 'test-$email', name: name, email: email));

  @override
  Future<AppUser> updateName(AppUser user, String name) =>
      _store(AppUser(id: user.id, name: name, email: user.email));

  @override
  Future<void> signOut() async =>
      (await SharedPreferences.getInstance()).remove(_key);

  @override
  Future<void> deleteAccount() => signOut();
}
