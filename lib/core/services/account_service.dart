import 'package:flutter/foundation.dart';
import 'package:moschee_app/core/data/account_repository.dart';
import 'package:moschee_app/core/models/app_user.dart';

/// Einziger Zugang der Screens zum Konto. Ohne Konto ist die App voll
/// lesbar; ein Konto braucht man nur zum Posten in der Community.
class AccountService extends ChangeNotifier {
  AccountService._();
  static final AccountService instance = AccountService._();

  /// Wird beim Einbau der Cloud ersetzt (z. B. Firebase Auth).
  AccountRepository repository = TestAccountRepository();

  AppUser? _user;
  AppUser? get user => _user;
  bool get signedIn => _user != null;

  /// Testkonten gibt es nur auf diesem Gerät.
  bool get isTestAccount => repository is TestAccountRepository;

  Future<void> init() async {
    _user = await repository.restore();
  }

  Future<void> signIn(String email, String password) async {
    _user = await repository.signIn(email: email, password: password);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _user = await repository.register(
      name: name,
      email: email,
      password: password,
    );
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    final user = _user;
    if (user == null) return;
    _user = await repository.updateName(user, name);
    notifyListeners();
  }

  Future<void> signOut() async {
    await repository.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await repository.deleteAccount();
    _user = null;
    notifyListeners();
  }
}
