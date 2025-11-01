import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/appointment.dart';

abstract class AppointmentDataSource {
  Future<List<Appointment>> getAllAppointments();
  Future<void> createAppointment(Appointment appointment);
  Future<void> cancelAppointment(String id);
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
}