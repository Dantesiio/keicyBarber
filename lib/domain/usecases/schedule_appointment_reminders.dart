import '../entities/appointment.dart';
import '../repositories/notification_repository.dart';

/// Caso de uso para programar recordatorios de citas
class ScheduleAppointmentReminders {
  final NotificationRepository repository;

  ScheduleAppointmentReminders(this.repository);

  Future<void> call(Appointment appointment) async {
    await repository.scheduleAppointmentReminders(appointment);
  }
}

