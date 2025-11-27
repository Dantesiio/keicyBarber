import '../repositories/appointment_repository.dart';

class RescheduleAppointment {
  final AppointmentRepository repository;

  RescheduleAppointment(this.repository);

  Future<void> call({
    required String appointmentId,
    required DateTime newStartTime,
    required int durationMinutes,
  }) async {
    return await repository.rescheduleAppointment(
      appointmentId: appointmentId,
      newStartTime: newStartTime,
      durationMinutes: durationMinutes,
    );
  }
}
