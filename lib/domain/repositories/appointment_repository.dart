import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();

  Future<void> createAppointment({
    required Appointment appointment,
    required List<int> serviceIds,
    required String barberId,
    required int locationId,
    required int totalDurationMinutes,
    required int estimatedPriceCents,
  });
  
  Future<void> cancelAppointment(String id);
}
