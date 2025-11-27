import '../entities/appointment.dart';
import '../repositories/email_repository.dart';

class SendAppointmentEmail {
  final EmailRepository emailRepository;

  SendAppointmentEmail(this.emailRepository);

  Future<void> call({
    required String recipientEmail,
    required String recipientName,
    required Appointment appointment,
  }) async {
    await emailRepository.sendAppointmentNotification(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      appointment: appointment,
    );
  }
}

