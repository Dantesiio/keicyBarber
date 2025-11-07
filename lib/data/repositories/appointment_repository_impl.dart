import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final SupabaseClient _sb = Supabase.instance.client;
    
  @override
  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Appointment(
        id: '1',
        serviceName: 'Corte Y Barba',
        dateTime: DateTime(2024, 1, 15, 10, 0),
        barberName: 'Carlos Rodríguez',
        location: 'Sede Bogotá',
        price: 45000,
        status: 'Confirmada',
      ),
    ];
  }

  @override
  Future<void> createAppointment({
    required Appointment appointment,
    required List<int> serviceIds,
    required String barberId,
    required int locationId,
    required int totalDurationMinutes,
    required int estimatedPriceCents,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Usuario no autenticado');

    final start = appointment.dateTime.toUtc();
    final end = start.add(Duration(minutes: totalDurationMinutes));
    final booking = _genBookingNumber();

    final inserted = await _sb
        .from('appointments')
        .insert({
          'booking_number': booking,
          'client_id': uid,
          'barber_id': barberId,
          'location_id': locationId,
          'start_time': start.toIso8601String(),
          'end_time': end.toIso8601String(),
          'total_duration_minutes': totalDurationMinutes,
          'estimated_price_cents': estimatedPriceCents,
          'final_price_cents': null,
          'status': 'pendiente',
        })
        .select('id')
        .single();

    final apptId = inserted['id'] as int;

    if (serviceIds.isNotEmpty) {
      final rows = serviceIds
          .map((sid) => {'appointment_id': apptId, 'service_id': sid})
          .toList();
      await _sb.from('appointment_services').insert(rows);
    }
  }

  @override
  Future<void> cancelAppointment(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock: simula cancelación exitosa
  }

  String _genBookingNumber() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = List.generate(4, (_) => chars[(DateTime.now().microsecond % chars.length)]).join();

    return 'BK-$y$m$d-$rand';
  }
}