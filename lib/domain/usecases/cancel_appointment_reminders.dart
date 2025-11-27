import '../repositories/notification_repository.dart';

/// Caso de uso para cancelar recordatorios de citas
class CancelAppointmentReminders {
  final NotificationRepository repository;

  CancelAppointmentReminders(this.repository);

  Future<void> call(String appointmentId) async {
    await repository.cancelAppointmentReminders(appointmentId);
  }
}

