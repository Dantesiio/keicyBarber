import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

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

  @override
  Future<List<TimeOfDay>> getAvailableSlots({
    required String barberId,
    required int locationId,
    required DateTime day,
    required int requiredMinutes,
    int slotMinutes = 30,
  }) async {
    final localDay = DateTime(day.year, day.month, day.day);

    final startOfDayUtc = DateTime.utc(localDay.year, localDay.month, localDay.day);
    final endOfDayUtc = startOfDayUtc.add(const Duration(days: 1));

    final rows = await _sb
        .from('appointments')
        .select('start_time, end_time')
        .eq('barber_id', barberId)
        .eq('location_id', locationId)
        .gte('start_time', startOfDayUtc.toIso8601String())
        .lt('start_time', endOfDayUtc.toIso8601String());

    final busy = <({DateTime start, DateTime end})>[];
    for (final r in (rows as List)) {
      final s = DateTime.parse(r['start_time'] as String).toLocal();
      final e = DateTime.parse(r['end_time'] as String).toLocal();
      busy.add((start: s, end: e));
    }

    List<DateTime> _generateWindow(DateTime base, int hStart, int hEnd) {
      final start = DateTime(base.year, base.month, base.day, hStart);
      final end = DateTime(base.year, base.month, base.day, hEnd);
      final lastStart = end.subtract(Duration(minutes: requiredMinutes));
      final step = Duration(minutes: slotMinutes);

      final out = <DateTime>[];
      for (DateTime t = start; !t.isAfter(lastStart); t = t.add(step)) {
        out.add(t);
      }
      return out;
    }

    final candidates = <DateTime>[
      ..._generateWindow(localDay, 9, 13),
      ..._generateWindow(localDay, 14, 19),
    ];

    bool _overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
      return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
    }

    final now = DateTime.now();
    final isToday = now.year == localDay.year && now.month == localDay.month && now.day == localDay.day;

    final available = <TimeOfDay>[];
    for (final start in candidates) {
      if (isToday && !start.isAfter(now)) continue;

      final end = start.add(Duration(minutes: requiredMinutes));
      final overlaps = busy.any((b) => _overlaps(start, end, b.start, b.end));
      if (!overlaps) {
        available.add(TimeOfDay(hour: start.hour, minute: start.minute));
      }
    }

    return available;
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