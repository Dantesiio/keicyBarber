import '../../domain/entities/appointment.dart';
import '../../domain/repositories/email_repository.dart';
import '../datasources/email_data_source.dart';
import 'package:intl/intl.dart';

class EmailRepositoryImpl implements EmailRepository {
  final EmailDataSource emailDataSource;

  EmailRepositoryImpl(this.emailDataSource);

  @override
  Future<void> sendAppointmentNotification({
    required String recipientEmail,
    required String recipientName,
    required Appointment appointment,
  }) async {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es');
    final timeFormat = DateFormat('h:mm a', 'es');

    final formattedDate = dateFormat.format(appointment.dateTime);
    final formattedTime = timeFormat.format(appointment.dateTime);
    final endTime = appointment.dateTime
        .add(Duration(minutes: appointment.durationMinutes));
    final formattedEndTime = timeFormat.format(endTime);

    final priceFormatted = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_CO',
    ).format(appointment.price / 100);

    final subject = 'Confirmación de Cita - Keicy Barber';

    final htmlBody = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background-color: #F2B705;
      color: #000;
      padding: 20px;
      text-align: center;
      border-radius: 8px 8px 0 0;
    }
    .content {
      background-color: #f9f9f9;
      padding: 30px;
      border-radius: 0 0 8px 8px;
    }
    .info-row {
      margin: 15px 0;
      padding: 10px;
      background-color: #fff;
      border-left: 4px solid #F2B705;
      border-radius: 4px;
    }
    .info-label {
      font-weight: bold;
      color: #666;
      font-size: 14px;
    }
    .info-value {
      color: #000;
      font-size: 16px;
      margin-top: 5px;
    }
    .footer {
      margin-top: 30px;
      padding-top: 20px;
      border-top: 1px solid #ddd;
      text-align: center;
      color: #666;
      font-size: 12px;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>¡Cita Confirmada!</h1>
  </div>
  <div class="content">
    <p>Hola <strong>$recipientName</strong>,</p>
    <p>Tu cita ha sido confirmada exitosamente. Aquí están los detalles:</p>
    
    <div class="info-row">
      <div class="info-label">Fecha</div>
      <div class="info-value">$formattedDate</div>
    </div>
    
    <div class="info-row">
      <div class="info-label">Hora</div>
      <div class="info-value">$formattedTime - $formattedEndTime</div>
    </div>
    
    <div class="info-row">
      <div class="info-label">Servicio</div>
      <div class="info-value">${appointment.serviceName}</div>
    </div>
    
    <div class="info-row">
      <div class="info-label">Barbero</div>
      <div class="info-value">${appointment.barberName}</div>
    </div>
    
    <div class="info-row">
      <div class="info-label">Ubicación</div>
      <div class="info-value">${appointment.location}</div>
    </div>
    
    <div class="info-row">
      <div class="info-label">Precio Estimado</div>
      <div class="info-value">$priceFormatted</div>
    </div>
    
    <div class="info-row">
      <div class="info-label">Estado</div>
      <div class="info-value">${appointment.status}</div>
    </div>
    
    <p style="margin-top: 30px;">
      Te esperamos en la fecha y hora acordada. Si necesitas cancelar o reagendar tu cita, 
      puedes hacerlo desde la aplicación.
    </p>
    
    <div class="footer">
      <p>Saludos,<br>El equipo de Keicy Barber</p>
    </div>
  </div>
</body>
</html>
''';

    await emailDataSource.sendEmail(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      htmlBody: htmlBody,
    );
  }
}

