/// Rollen in einer Moschee (siehe Konzept, Abschnitt 3).
enum MosqueRole { owner, admin, editor }

/// Mitglied im Verwaltungsteam einer Moschee.
class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    this.isMe = false,
  });

  final String id;
  final String name;
  final MosqueRole role;
  final bool isMe;

  TeamMember copyWith({MosqueRole? role}) =>
      TeamMember(id: id, name: name, role: role ?? this.role, isMe: isMe);
}
