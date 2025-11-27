import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EmailDataSource {
  Future<void> sendEmail({
    required String recipientEmail,
    required String recipientName,
    required String subject,
    required String htmlBody,
  });
}

class EmailDataSourceImpl implements EmailDataSource {
  @override
  Future<void> sendEmail({
    required String recipientEmail,
    required String recipientName,
    required String subject,
    required String htmlBody,
  }) async {
    final smtpEmail = dotenv.env['GMAIL_EMAIL'];
    final smtpPassword = dotenv.env['GMAIL_APP_PASSWORD'];

    if (smtpEmail == null || smtpPassword == null) {
      throw Exception(
          'GMAIL_EMAIL y GMAIL_APP_PASSWORD deben estar configurados en .env');
    }

    final smtpServer = gmail(smtpEmail, smtpPassword);

    final message = Message()
      ..from = Address(smtpEmail, 'Keicy Barber')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..html = htmlBody;

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Error enviando correo: $e');
    }
  }
}

