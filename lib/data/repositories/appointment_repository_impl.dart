import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final SupabaseClient _sb = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // 🔍 OBTENER CITAS — SOLO LAS DEL USUARIO AUTENTICADO
  // ---------------------------------------------------------------------------
  @override
  Future<List<Appointment>> getAppointments() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];

    try {
      final rows = await _sb
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

      return (rows as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      print("❌ Error al cargar citas: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 🧠 VALIDACIÓN: NO PERMITIR CITAS QUE SE EMPALMEN PARA EL MISMO USUARIO
  // ---------------------------------------------------------------------------
  Future<void> _validateUserNoOverlap({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _sb
        .from('appointments')
        .select('start_time, end_time')
        .eq('client_id', uid);

    for (final r in (rows as List)) {
      final s = DateTime.parse(r['start_time']).toUtc();
      final e = DateTime.parse(r['end_time']).toUtc();

      final overlap = start.isBefore(e) && s.isBefore(end);
      if (overlap) throw Exception("Ya tienes una cita en ese horario.");
    }
  }

  // ---------------------------------------------------------------------------
  // 🧠 VALIDACIÓN: NO PERMITIR CITAS EMPALMADAS DEL BARBERO
  // ---------------------------------------------------------------------------
  Future<void> _validateBarberNoOverlap({
    required String barberId,
    required int locationId,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _sb
        .from('appointments')
        .select('start_time, end_time')
        .eq('barber_id', barberId)
        .eq('location_id', locationId);

    for (final r in (rows as List)) {
      final s = DateTime.parse(r['start_time']).toUtc();
      final e = DateTime.parse(r['end_time']).toUtc();

      final overlap = start.isBefore(e) && s.isBefore(end);
      if (overlap) throw Exception("El barbero ya tiene una cita en ese horario.");
    }
  }

  // ---------------------------------------------------------------------------
  // 🧾 CREAR CITA — YA CON VALIDACIONES REALES
  // ---------------------------------------------------------------------------
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

    final startLocal = appointment.dateTime;
    final startUtc = startLocal.toUtc();
    final endUtc = startUtc.add(Duration(minutes: totalDurationMinutes));
    final booking = _genBookingNumber();

    // ---------------------------------------------------------
    // 🧠 VALIDACIONES (usuario y barbero)
    // ---------------------------------------------------------
    await _validateUserNoOverlap(
      uid: uid,
      start: startUtc,
      end: endUtc,
    );

    await _validateBarberNoOverlap(
      barberId: barberId,
      locationId: locationId,
      start: startUtc,
      end: endUtc,
    );

    // ---------------------------------------------------------
    // 📝 INSERT PRINCIPAL
    // ---------------------------------------------------------
    final inserted = await _sb
        .from('appointments')
        .insert({
          'booking_number': booking,
          'client_id': uid,
          'barber_id': barberId,
          'location_id': locationId,
          'start_time': startUtc.toIso8601String(),
          'end_time': endUtc.toIso8601String(),
          'total_duration_minutes': totalDurationMinutes,
          'estimated_price_cents': estimatedPriceCents,
          'final_price_cents': null,
          'status': 'pendiente',
        })
        .select('id')
        .single();

    final apptId = inserted['id'] as int;

    // ---------------------------------------------------------
    // 🧾 INSERT A appointment_services
    // ---------------------------------------------------------
    if (serviceIds.isNotEmpty) {
      final rows = serviceIds
          .map((sid) => {'appointment_id': apptId, 'service_id': sid})
          .toList();

      await _sb.from('appointment_services').insert(rows);
    }
  }

  // ---------------------------------------------------------------------------
  // ❌ CANCELAR CITA
  // ---------------------------------------------------------------------------
  @override
  Future<void> cancelAppointment(String id) async {
    try {
      await _sb
          .from('appointments')
          .update({'status': 'cancelada_cliente'})
          .eq('id', id);
    } catch (e) {
      print("❌ Error al cancelar cita: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 🕒 SLOTS DISPONIBLES — CORREGIDA LÓGICA Y DURACIÓN VARIABLE
  // ---------------------------------------------------------------------------
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
      final s = DateTime.parse(r['start_time']).toUtc().toLocal();
      final e = DateTime.parse(r['end_time']).toUtc().toLocal();
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
    final isToday = now.year == localDay.year &&
        now.month == localDay.month &&
        now.day == localDay.day;

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

  // ---------------------------------------------------------------------------
  // 🎫 GENERADOR BOOKING NUMBER
  // ---------------------------------------------------------------------------
  String _genBookingNumber() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = List.generate(
      4,
      (_) => chars[(DateTime.now().microsecond % chars.length)],
    ).join();

    return 'BK-$y$m$d-$rand';
  }
}