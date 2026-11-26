// Nach lib/cloud/groups/ kopieren. Siehe cloud_template/README.md.
import 'package:moschee_app/cloud/groups/group_invite.dart';
import 'package:moschee_app/cloud/groups/group_roles.dart';

/// Ergebnis beim Einlösen bzw. Prüfen einer Einladung. Die Werte
/// entsprechen den Status-Texten der Cloud Function `redeemGroupInvite`.
enum InviteRedemptionStatus {
  joined,

  /// Nur bei `check`: Beitritt wäre möglich.
  canJoin,
  alreadyMember,
  expired,
  invalid,
  blocked;

  static InviteRedemptionStatus parse(Object? value) =>
      InviteRedemptionStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => InviteRedemptionStatus.invalid,
      );
}

class InviteRedemption {
  const InviteRedemption(this.status, {this.groupId});

  final InviteRedemptionStatus status;
  final String? groupId;
}

/// Rollen und Einladungen einer Gruppe.
///
/// Screens bekommen diese Schnittstelle per Konstruktor, damit sie sich in
/// Widget-Tests durch eine Fake-Implementierung ersetzen lässt.
/// Firestore-Umsetzung: `FirestoreGroupAccess`.
abstract class GroupAccess {
  /// Rechte des angemeldeten Nutzers, live (entzogene Rechte kommen sofort an).
  Stream<GroupPermissions> watchPermissions(String groupId);

  /// Rolle eines Mitglieds ändern (nur Inhaber; über Cloud Function).
  Future<void> setRole({
    required String groupId,
    required String uid,
    required GroupRole role,
  });

  Future<GroupInvite> createInvite({
    required String groupId,
    required String groupName,
    required Duration validFor,
    int? maxUses,
    GroupRole role = GroupRole.member,
  });

  /// Alle Einladungen der Gruppe, neueste zuerst (nur für Admins lesbar).
  Stream<List<GroupInvite>> watchInvites(String groupId);

  Future<GroupInvite?> getInvite(String token);

  Future<void> revokeInvite(String token);

  Future<InviteRedemption> redeemInvite(String token);

  /// Prüft vorab, ob der Nutzer beitreten könnte, ohne beizutreten.
  Future<InviteRedemptionStatus> checkInvite(String token);
}
