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

  Map<String, dynamic> toJson() {
    return {
      'start_time': dateTime.toIso8601String(),
      'status': _mapStatusToEnglish(status),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String serviceName = 'Sin servicio';
    double price = 0;

    if (json['appointment_services'] != null &&
        (json['appointment_services'] as List).isNotEmpty) {
      final serviceData = (json['appointment_services'] as List)[0];
      if (serviceData['services'] != null) {
        serviceName =
            serviceData['services']['name'] as String? ?? 'Sin servicio';
        final priceCents = serviceData['services']['price_cents'] as int? ?? 0;
        price = priceCents * 1;
      }
    }

    String barberName = 'Sin asignar';
    if (json['barbers'] != null && json['barbers']['profiles'] != null) {
      final profile = json['barbers']['profiles'];
      final firstName = profile['first_name'] as String? ?? '';
      final lastName = profile['last_name'] as String? ?? '';
      barberName = '$firstName $lastName'.trim();
      if (barberName.isEmpty) barberName = 'Sin asignar';
    }

    String locationName = 'Sin ubicación';
    if (json['locations'] != null && json['locations']['name'] != null) {
      locationName = json['locations']['name'] as String;
    }

    final statusRaw = json['status'] as String? ?? 'pending';
    String statusSpanish = _mapStatusToSpanish(statusRaw);

    return Appointment(
      id: json['id'].toString(),
      serviceName: serviceName,
      dateTime: DateTime.parse(json['start_time'] as String),
      barberName: barberName,
      location: locationName,
      price: price,
      status: statusSpanish,
    );
  }

  static String _mapStatusToSpanish(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
      case 'confirmed':
        return 'Confirmada';
      case 'en_proceso':
        return 'En Proceso';
      case 'completada':
      case 'completed':
        return 'Completada';
      case 'cancelada_cliente':
      case 'cancelada_admin':
      case 'cancelada':
      case 'cancelled':
        return 'Cancelada';
      case 'pendiente':
      case 'pending':
        return 'Pendiente';
      case 'no_show':
        return 'No Asistió';
      default:
        return 'Desconocido';
    }
  }

  static String _mapStatusToEnglish(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return 'confirmed';
      case 'completada':
        return 'completed';
      case 'cancelada':
        return 'cancelled';
      case 'pendiente':
        return 'pending';
      default:
        return 'pending';
    }
  }
}
