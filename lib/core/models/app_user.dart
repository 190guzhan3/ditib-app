/// Angemeldetes Konto (nur, was die App anzeigt).
class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}
