class Profile {
  String id; // UID de Supa
  final String firstName;
  final String lastName;
  final String email; // PONER EN LA TABLE PROFILES
  final DateTime? birthDate;
  final String? phone;
  // Los campos role, status, created_at, updated_at los maneja Supabase por defecto.

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.birthDate,
    this.phone,
  });

  // Para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
    };
  }
}
