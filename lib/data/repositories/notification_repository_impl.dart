import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/notification_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/notification_repository.dart';

/// Implementación del repositorio de notificaciones
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _notificationService;
  final SupabaseClient _supabaseClient;

  NotificationRepositoryImpl({
    required NotificationService notificationService,
    required SupabaseClient supabaseClient,
  })  : _notificationService = notificationService,
        _supabaseClient = supabaseClient;

  @override
  Future<void> scheduleAppointmentReminders(Appointment appointment) async {
    // Programar notificaciones locales
    await _notificationService.scheduleAppointmentReminders(
      appointmentId: appointment.id,
      appointmentDateTime: appointment.dateTime,
      barberName: appointment.barberName,
      location: appointment.location,
      serviceName: appointment.serviceName,
    );

    // Programar envío de emails (se ejecutará desde el backend)
    // Esto se puede hacer mediante Supabase Edge Functions o Database Triggers
    await _scheduleEmailReminders(appointment);
  }

  @override
  Future<void> cancelAppointmentReminders(String appointmentId) async {
    await _notificationService.cancelAppointmentReminders(appointmentId);
  }

  @override
  Future<void> sendEmailReminder({
    required String email,
    required Appointment appointment,
    required int hoursBefore,
  }) async {
    // Esta función se puede llamar desde el backend (Supabase Edge Function)
    // Por ahora, solo registramos la acción
    try {
      // Aquí podrías llamar a una Supabase Edge Function
      // Ejemplo:
      // await _supabaseClient.functions.invoke(
      //   'send-email-reminder',
      //   body: {
      //     'email': email,
      //     'appointment_id': appointment.id,
      //     'hours_before': hoursBefore,
      //   },
      // );
      
      print('Email reminder scheduled for $email - ${hoursBefore}h before appointment ${appointment.id}');
    } catch (e) {
      print('Error scheduling email reminder: $e');
      // No lanzamos error para no interrumpir el flujo principal
    }
  }

  /// Programa los recordatorios de email
  Future<void> _scheduleEmailReminders(Appointment appointment) async {
    try {
      // Obtener el email del usuario actual
      final user = _supabaseClient.auth.currentUser;
      if (user?.email == null) return;

      final email = user!.email!;

      // Calcular fechas de recordatorio
      final reminder24h = appointment.dateTime.subtract(const Duration(hours: 24));
      final reminder2h = appointment.dateTime.subtract(const Duration(hours: 2));

      // Solo programar si la fecha de recordatorio es en el futuro
      if (reminder24h.isAfter(DateTime.now())) {
        await sendEmailReminder(
          email: email,
          appointment: appointment,
          hoursBefore: 24,
        );
      }

      if (reminder2h.isAfter(DateTime.now())) {
        await sendEmailReminder(
          email: email,
          appointment: appointment,
          hoursBefore: 2,
        );
      }
    } catch (e) {
      print('Error scheduling email reminders: $e');
      // No lanzamos error para no interrumpir el flujo principal
    }
  }
}

