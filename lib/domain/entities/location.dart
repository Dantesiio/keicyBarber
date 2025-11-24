class Location {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  Location({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });
}