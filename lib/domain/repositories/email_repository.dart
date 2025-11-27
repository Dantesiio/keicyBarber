import '../entities/appointment.dart';

abstract class EmailRepository {
  Future<void> sendAppointmentNotification({
    required String recipientEmail,
    required String recipientName,
    required Appointment appointment,
  });
}

