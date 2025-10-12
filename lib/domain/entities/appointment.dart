class Appointment {
  final String id;
  final String serviceName;
  final DateTime dateTime;
  final String barberName;
  final String location;
  final double price;
  final String status;

  Appointment({
    required this.id,
    required this.serviceName,
    required this.dateTime,
    required this.barberName,
    required this.location,
    required this.price,
    required this.status,
  });
}
