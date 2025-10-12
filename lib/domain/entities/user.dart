class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int points;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.points,
  });
}
