// Nach lib/cloud/groups/ kopieren. Siehe cloud_template/README.md.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moschee_app/cloud/groups/group_access.dart';
import 'package:moschee_app/cloud/groups/group_invite.dart';
import 'package:moschee_app/cloud/groups/group_roles.dart';

/// [GroupAccess] über Firestore und Cloud Functions.
///
/// Datenmodell:
/// - `groups/{groupId}`: `name`, `ownerId`, `createdAt`, …
/// - `groups/{groupId}/members/{uid}`: `uid`, `role`, `joinedAt`
/// - `groupInvites/{token}`: siehe [GroupInvite]
///
/// Lesen und Anlegen/Widerrufen von Einladungen erlauben die Regeln direkt;
/// Einlösen und Rollen ändern laufen über Functions (`redeemGroupInvite`,
/// `setGroupRole`), weil sie fremde Dokumente schreiben.
class FirestoreGroupAccess implements GroupAccess {
  FirestoreGroupAccess({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _invites =>
      _db.collection('groupInvites');

  @override
  Stream<GroupPermissions> watchPermissions(String groupId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(GroupPermissions.none);
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .snapshots()
        .map(
          (snap) => GroupPermissions(
            snap.exists ? GroupRole.parse(snap.data()?['role']) : null,
          ),
        )
        // Kein Zugriff mehr (entfernt, Gruppe gelöscht): keine Rechte.
        .handleError((_) => GroupPermissions.none);
  }

  @override
  Future<void> setRole({
    required String groupId,
    required String uid,
    required GroupRole role,
  }) async {
    await _functions.httpsCallable('setGroupRole').call<Object?>({
      'groupId': groupId,
      'uid': uid,
      'role': role.name,
    });
  }

  @override
  Future<GroupInvite> createInvite({
    required String groupId,
    required String groupName,
    required Duration validFor,
    int? maxUses,
    GroupRole role = GroupRole.member,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht angemeldet');
    final token = GroupInviteLinks.generateToken();
    final expiresAt = DateTime.now().add(validFor);
    await _invites.doc(token).set({
      'token': token,
      'groupId': groupId,
      'groupName': groupName,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'role': role.name,
      'maxUses': maxUses,
      'useCount': 0,
      'revoked': false,
    });
    return GroupInvite(
      token: token,
      groupId: groupId,
      groupName: groupName,
      createdBy: uid,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      role: role.name,
      maxUses: maxUses,
    );
  }

  @override
  Stream<List<GroupInvite>> watchInvites(String groupId) => _invites
      .where('groupId', isEqualTo: groupId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => [for (final d in q.docs) _fromDoc(d.data())]);

  @override
  Future<GroupInvite?> getInvite(String token) async {
    final snap = await _invites.doc(token).get();
    final data = snap.data();
    return data == null ? null : _fromDoc(data);
  }

  @override
  Future<void> revokeInvite(String token) =>
      _invites.doc(token).update({'revoked': true});

  @override
  Future<InviteRedemption> redeemInvite(String token) async {
    final data = await _callRedeem(token, dryRun: false);
    return InviteRedemption(
      InviteRedemptionStatus.parse(data['status']),
      groupId: data['groupId'] as String?,
    );
  }

  @override
  Future<InviteRedemptionStatus> checkInvite(String token) async =>
      InviteRedemptionStatus.parse(
        (await _callRedeem(token, dryRun: true))['status'],
      );

  Future<Map<String, dynamic>> _callRedeem(
    String token, {
    required bool dryRun,
  }) async {
    final result = await _functions
        .httpsCallable('redeemGroupInvite')
        .call<Object?>({'token': token, 'dryRun': dryRun});
    final data = result.data;
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }

  static GroupInvite _fromDoc(Map<String, dynamic> data) {
    DateTime? date(Object? v) => v is Timestamp ? v.toDate() : null;
    return GroupInvite.fromJson({
      ...data,
      // Bei frisch angelegten Dokumenten steht der Server-Zeitstempel noch aus.
      'createdAt': date(data['createdAt']) ?? DateTime.now(),
      'expiresAt': date(data['expiresAt']) ?? DateTime.now(),
    });
  }
}
