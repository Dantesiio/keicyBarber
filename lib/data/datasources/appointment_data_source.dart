import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDataSource {
  final SupabaseClient _sb;

  AppointmentDataSource(this._sb);

  Future<List<Map<String, dynamic>>> fetchAppointments(String uid) async {
    return await _sb
        .from('appointments')
        .select('''
          id,
          start_time,
          end_time,
          status,
          estimated_price_cents,
          appointment_services(
            services(
              name,
              price_cents
            )
          ),
          barbers(
            profiles(
              first_name,
              last_name
            )
          ),
          locations(
            name,
            address
          )
        ''')
        .eq('client_id', uid)
        .order('start_time', ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchAppointmentsByUser(String uid) async {
    return await _sb
        .from('appointments')
        .select('start_time, end_time')
        .eq('client_id', uid);
  }

  Future<List<Map<String, dynamic>>> fetchAppointmentsByBarber({
    required String barberId,
    required int locationId,
  }) async {
    return await _sb
        .from('appointments')
        .select('start_time, end_time')
        .eq('barber_id', barberId)
        .eq('location_id', locationId);
  }

  Future<int> insertAppointment(Map<String, dynamic> data) async {
    final inserted = await _sb
        .from('appointments')
        .insert(data)
        .select('id')
        .single();

    return inserted['id'] as int;
  }

  Future<void> insertAppointmentServices(List<Map<String, dynamic>> rows) async {
    await _sb.from('appointment_services').insert(rows);
  }

  Future<void> cancel(String id) async {
    await _sb
        .from('appointments')
        .update({'status': 'cancelada_cliente'})
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchDayAppointments({
    required String barberId,
    required int locationId,
    required String from,
    required String to,
  }) async {
    return await _sb
        .from('appointments')
        .select('start_time, end_time')
        .eq('barber_id', barberId)
        .eq('location_id', locationId)
        .gte('start_time', from)
        .lt('start_time', to);
  }

  Future<Map<String, dynamic>?> fetchNextAppointment(String uid) async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    return await _sb
        .from('appointments')
        .select('''
          id,
          start_time,
          end_time,
          status,
          estimated_price_cents,
          appointment_services(
            services(
              name,
              price_cents
            )
          ),
          barbers(
            profiles(
              first_name,
              last_name
            )
          ),
          locations(
            name,
            address
          )
        ''')
        .eq('client_id', uid)
        .eq('status', 'programada')
        .gte('start_time', nowUtc)
        .order('start_time', ascending: true)
        .limit(1)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> fetchAppointmentById(String appointmentId) async {
    return await _sb
        .from('appointments')
        .select('''
          id,
          start_time,
          end_time,
          status,
          estimated_price_cents,
          appointment_services(
            services(
              name,
              price_cents
            )
          ),
          barbers(
            profiles(
              first_name,
              last_name
            )
          ),
          locations(
            name,
            address
          )
        ''')
        .eq('id', appointmentId)
        .single();
  }
}