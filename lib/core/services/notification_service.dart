import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Servicio para manejar notificaciones locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos en Android 13+
    if (await _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ??
        false) {
      _initialized = true;
    } else {
      _initialized = true; // Continuar aunque no se otorguen permisos
    }
  }

  /// Maneja cuando el usuario toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    // Aquí puedes navegar a la pantalla de citas si es necesario
    print('Notificación tocada: ${response.payload}');
  }

  /// Programa una notificación local
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Convertir DateTime a TZDateTime
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Configuración para Android
    const androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Recordatorios de Citas',
      channelDescription: 'Notificaciones para recordar citas agendadas',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    // Configuración para iOS
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela una notificación programada
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Programa recordatorios para una cita (24h y 2h antes)
  Future<void> scheduleAppointmentReminders({
    required String appointmentId,
    required DateTime appointmentDateTime,
    required String barberName,
    required String location,
    required String serviceName,
  }) async {
    // Cancelar notificaciones previas de esta cita si existen
    final id24h = _getNotificationId24h(appointmentId);
    final id2h = _getNotificationId2h(appointmentId);
    await cancelNotification(id24h);
    await cancelNotification(id2h);

    // Calcular fechas de recordatorio
    final reminder24h = appointmentDateTime.subtract(const Duration(hours: 24));
    final reminder2h = appointmentDateTime.subtract(const Duration(hours: 2));

    // Solo programar si la fecha de recordatorio es en el futuro
    if (reminder24h.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: id24h,
        title: 'Recordatorio de Cita - 24 horas',
        body: 'Tienes una cita mañana a las ${_formatTime(appointmentDateTime)} con $barberName en $location. Servicio: $serviceName',
        scheduledDate: reminder24h,
        payload: appointmentId,
      );
    }

    if (reminder2h.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: id2h,
        title: 'Recordatorio de Cita - 2 horas',
        body: 'Tu cita es en 2 horas a las ${_formatTime(appointmentDateTime)} con $barberName en $location. Servicio: $serviceName',
        scheduledDate: reminder2h,
        payload: appointmentId,
      );
    }
  }

  /// Cancela los recordatorios de una cita
  Future<void> cancelAppointmentReminders(String appointmentId) async {
    final id24h = _getNotificationId24h(appointmentId);
    final id2h = _getNotificationId2h(appointmentId);
    await cancelNotification(id24h);
    await cancelNotification(id2h);
  }

  /// Genera un ID único para la notificación de 24h
  int _getNotificationId24h(String appointmentId) {
    return ('24h_$appointmentId').hashCode.abs() % 2147483647;
  }

  /// Genera un ID único para la notificación de 2h
  int _getNotificationId2h(String appointmentId) {
    return ('2h_$appointmentId').hashCode.abs() % 2147483647;
  }

  /// Formatea la hora para mostrar en la notificación
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

