/// Contacto del directorio, tal como viene en `assets/contacts.json`.
class Contact {
  final int id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final bool active;

  const Contact({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.active,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      active: json['active'] as bool,
    );
  }

  /// Iniciales para la burbuja de contacto: "Camila Reyes" → "CR".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  bool operator ==(Object other) => other is Contact && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
