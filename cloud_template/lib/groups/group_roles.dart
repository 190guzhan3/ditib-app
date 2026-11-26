// Nach lib/cloud/groups/ kopieren. Siehe cloud_template/README.md.

/// Rolle in einer Gruppe (Team, Verein, Gemeinde …).
///
/// Gespeichert in `groups/{groupId}/members/{uid}.role`. Ändern darf sie nur
/// die Cloud Function `setGroupRole`, nie der Client direkt.
enum GroupRole {
  owner,
  admin,
  member;

  static GroupRole? parse(Object? value) => switch (value) {
    'owner' => GroupRole.owner,
    'admin' => GroupRole.admin,
    'member' => GroupRole.member,
    _ => null,
  };
}

/// Was der aktuelle Nutzer in einer Gruppe darf.
///
/// Nur für die Oberfläche (Buttons zeigen/verstecken). Maßgeblich sind die
/// Firestore-Regeln und Cloud Functions; sie prüfen dasselbe noch einmal.
class GroupPermissions {
  const GroupPermissions(this.role);

  /// `null` = kein Mitglied.
  final GroupRole? role;

  static const none = GroupPermissions(null);

  bool get isMember => role != null;
  bool get isAdmin => role == GroupRole.owner || role == GroupRole.admin;
  bool get isOwner => role == GroupRole.owner;

  /// Inhalte der Gruppe anlegen und bearbeiten.
  bool get canEditContent => isAdmin;

  /// Name, Bild, Beschreibung der Gruppe ändern.
  bool get canEditGroup => isAdmin;

  /// Einladungen erstellen und widerrufen, Mitglieder entfernen.
  bool get canManageMembers => isAdmin;

  /// Admins ernennen oder absetzen.
  bool get canManageRoles => isOwner;

  bool get canDeleteGroup => isOwner;

  /// Darf [target] von [from] auf [to] gesetzt werden? Spiegelt die Prüfung
  /// in `functions/group_access.js` (`evaluateRoleChange`).
  bool canChangeRole({
    required bool targetIsSelf,
    required GroupRole from,
    required GroupRole to,
  }) {
    if (!isOwner || targetIsSelf) return false;
    // Inhaber wechselt nur über eine eigene Übergabe, nicht hier.
    return from != GroupRole.owner && to != GroupRole.owner;
  }
}
