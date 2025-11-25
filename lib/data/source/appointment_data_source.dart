import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/appointment.dart';

abstract class AppointmentDataSource {
  Future<List<Appointment>> getAllAppointments();
  Future<void> createAppointment(Appointment appointment);
  Future<void> cancelAppointment(String id);
  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    int durationMinutes,
  );
}

class AppointmentDataSourceImpl extends AppointmentDataSource {
  @override
  Future<List<Appointment>> getAllAppointments() async {
    print("Obteniendo citas desde Supabase con JOINs");

    var list = await Supabase.instance.client
        .from("appointments")
        .select('''
          id,
          booking_number,
          start_time,
          end_time,
          status,
          final_price_cents,
          barbers!inner(
            profile_id,
            profiles!inner(
              first_name,
              last_name
            )
          ),
          locations!inner(
            id,
            name,
            address
          ),
          appointment_services!inner(
            service_id,
            services!inner(
              id,
              name,
              description,
              duration_minutes,
              price_cents
            )
          )
        ''')
        .order("start_time", ascending: false);

    print("Citas obtenidas: ${list.length}");
    print("Datos crudos: $list");

    return list.map((json) => Appointment.fromJson(json)).toList();
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
    print("Creando cita en Supabase");
    await Supabase.instance.client
        .from("appointments")
        .insert(appointment.toJson());
    print("Cita creada exitosamente");
  }

  @override
  Future<void> cancelAppointment(String id) async {
    print("Cancelando cita: $id");
    await Supabase.instance.client
        .from("appointments")
        .update({'status': 'cancelled'})
        .eq('id', id);
    print("Cita cancelada exitosamente");
  }

  @override
  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    int durationMinutes,
  ) async {
    final newEndTime = newStartTime.add(Duration(minutes: durationMinutes));

    // Convertir a formato ISO8601 para Supabase
    final startIso = newStartTime.toIso8601String();
    final endIso = newEndTime.toIso8601String();

    final response = await Supabase.instance.client
        .from('appointments')
        .select('reschedule_count')
        .eq('id', appointmentId)
        .single();

    final currentCount = response['reschedule_count'] as int? ?? 0;

    await Supabase.instance.client
        .from('appointments')
        .update({
          'start_time': startIso,
          'end_time': endIso,
          'reschedule_count': currentCount + 1,
          'updated_at': DateTime.now().toIso8601String(),
          'status':
              'pendiente', // Opcional: ¿Vuelve a pendiente o se queda confirmada? Usualmente pendiente de re-confirmación.
        })
        .eq('id', appointmentId);
  }
}
