import '../entities/appointment.dart';

/// Repositorio para manejar notificaciones
abstract class NotificationRepository {
  /// Programa recordatorios para una cita (24h y 2h antes)
  Future<void> scheduleAppointmentReminders(Appointment appointment);

  /// Cancela los recordatorios de una cita
  Future<void> cancelAppointmentReminders(String appointmentId);

  /// Envía un email de recordatorio (se implementará en el backend)
  Future<void> sendEmailReminder({
    required String email,
    required Appointment appointment,
    required int hoursBefore,
  });
}

