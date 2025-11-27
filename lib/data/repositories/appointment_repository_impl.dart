import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentDataSource dataSource;

  AppointmentRepositoryImpl(this.dataSource);

  @override
  Future<List<Appointment>> getAppointments() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return [];

    try {
      final rows = await Supabase.instance.client
          .from('appointments')
          .select('''
            id,
            start_time,
            status,
            barber_id,              
            location_id,            
            total_duration_minutes, 
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
              name
            )
          ''')
          .eq('client_id', uid)
          .order('start_time', ascending: false);

      final appointments = (rows as List)
          .map((json) => Appointment.fromJson(json))
          .toList();

      return appointments;
    } catch (e) {
      throw AppException("Error inesperado obteniendo citas");
    }
  }

  Future<void> _validateUserNoOverlap({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final rows = await dataSource.fetchAppointmentsByUser(uid);

      for (final r in rows) {
        final s = DateTime.parse(r['start_time']).toUtc();
        final e = DateTime.parse(r['end_time']).toUtc();

        final overlap = start.isBefore(e) && s.isBefore(end);
        if (overlap) {
          throw AppException("Ya tienes una cita en ese horario", code: "USER_OVERLAP");
        }
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException("Error validando disponibilidad del usuario");
    }
  }

  Future<void> _validateBarberNoOverlap({
    required String barberId,
    required int locationId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final rows = await dataSource.fetchAppointmentsByBarber(
        barberId: barberId,
        locationId: locationId,
      );

      for (final r in rows) {
        final s = DateTime.parse(r['start_time']).toUtc();
        final e = DateTime.parse(r['end_time']).toUtc();

        final overlap = start.isBefore(e) && s.isBefore(end);
        if (overlap) {
          throw AppException(
            "El barbero ya tiene una cita en ese horario",
            code: "BARBER_OVERLAP",
          );
        }
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException("Error validando disponibilidad del barbero");
    }
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
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      throw AppException('Usuario no autenticado', code: "NO_AUTH");
    }

    final startLocal = appointment.dateTime;
    final startUtc = startLocal.toUtc();
    final endUtc = startUtc.add(Duration(minutes: totalDurationMinutes));

    try {
      await _validateUserNoOverlap(uid: uid, start: startUtc, end: endUtc);
      await _validateBarberNoOverlap(
        barberId: barberId,
        locationId: locationId,
        start: startUtc,
        end: endUtc,
      );

      final apptId = await dataSource.insertAppointment({
        'booking_number': _genBookingNumber(),
        'client_id': uid,
        'barber_id': barberId,
        'location_id': locationId,
        'start_time': startUtc.toIso8601String(),
        'end_time': endUtc.toIso8601String(),
        'total_duration_minutes': totalDurationMinutes,
        'estimated_price_cents': estimatedPriceCents,
        'final_price_cents': null,
        'status': 'pendiente',
      });

      if (serviceIds.isNotEmpty) {
        final rows = serviceIds
            .map((sid) => {'appointment_id': apptId, 'service_id': sid})
            .toList();

        await dataSource.insertAppointmentServices(rows);
      }
    } on AppException {
      rethrow;
    } on PostgrestException catch (_) {
      throw AppException("Error guardando la cita", code: "DB_INSERT");
    } catch (e) {
      throw AppException("Error inesperado guardando cita");
    }
  }

  @override
  Future<void> cancelAppointment(String id) async {
    try {
      await dataSource.cancel(id);
    } on PostgrestException {
      throw AppException("No se pudo cancelar la cita", code: "DB_CANCEL");
    } catch (_) {
      throw AppException("Error inesperado cancelando la cita");
    }
  }

  @override
  Future<List<TimeOfDay>> getAvailableSlots({
    required String barberId,
    required int locationId,
    required DateTime day,
    required int requiredMinutes,
    int slotMinutes = 30,
  }) async {
    try {
      final localDay = DateTime(day.year, day.month, day.day);

      final startOfDayUtc = DateTime.utc(localDay.year, localDay.month, localDay.day);
      final endOfDayUtc = startOfDayUtc.add(const Duration(days: 1));

      final rows = await dataSource.fetchDayAppointments(
        barberId: barberId,
        locationId: locationId,
        from: startOfDayUtc.toIso8601String(),
        to: endOfDayUtc.toIso8601String(),
      );

      final busy = <({DateTime start, DateTime end})>[];

      for (final r in rows) {
        final s = DateTime.parse(r['start_time']).toUtc().toLocal();
        final e = DateTime.parse(r['end_time']).toUtc().toLocal();
        busy.add((start: s, end: e));
      }

      List<DateTime> gen(DateTime base, int hStart, int hEnd) {
        final start = DateTime(base.year, base.month, base.day, hStart);
        final end = DateTime(base.year, base.month, base.day, hEnd);

        final lastStart = end.subtract(Duration(minutes: requiredMinutes));
        final step = Duration(minutes: slotMinutes);

        return [
          for (var t = start; !t.isAfter(lastStart); t = t.add(step)) t,
        ];
      }

      final candidates = [
        ...gen(localDay, 9, 13),
        ...gen(localDay, 14, 19),
      ];

      bool overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
          aStart.isBefore(bEnd) && bStart.isBefore(aEnd);

      final now = DateTime.now();
      final isToday = now.year == localDay.year &&
          now.month == localDay.month &&
          now.day == localDay.day;

      final available = <TimeOfDay>[];

      for (final start in candidates) {
        if (isToday && !start.isAfter(now)) continue;

        final end = start.add(Duration(minutes: requiredMinutes));
        final conflict = busy.any((b) => overlaps(start, end, b.start, b.end));

        if (!conflict) {
          available.add(TimeOfDay(hour: start.hour, minute: start.minute));
        }
      }

      return available;
    } catch (e) {
      throw AppException("No se pudieron obtener los horarios disponibles");
    }
  }

  String _genBookingNumber() {
    final now = DateTime.now();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');

    final rand = List.generate(
      4,
      (_) => chars[(DateTime.now().microsecond % chars.length) % chars.length],
    ).join();

    return 'BK-$y$m$d-$rand';
  }

  @override
  Future<Appointment?> getNextAppointment() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final row = await dataSource.fetchNextAppointment(uid);
      if (row == null) return null;
      return Appointment.fromJson(row);
    } on PostgrestException catch (_) {
      throw AppException("Error obteniendo la próxima cita", code: "DB_FETCH");
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException("Error inesperado obteniendo la próxima cita");
    }
  }

    @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newStartTime,
    required int durationMinutes,
  }) async {
    try {
      final startUtc = newStartTime.toUtc();
      final endUtc = startUtc.add(Duration(minutes: durationMinutes));

      final res = await Supabase.instance.client
          .from('appointments')
          .select('reschedule_count')
          .eq('id', appointmentId)
          .single();

      final currentCount = res['reschedule_count'] as int? ?? 0;

      await Supabase.instance.client
          .from('appointments')
          .update({
            'start_time': startUtc.toIso8601String(),
            'end_time': endUtc.toIso8601String(),
            'reschedule_count': currentCount + 1,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'status': 'pendiente',
          })
          .eq('id', appointmentId);
    } catch (e) {
      print("❌ Error al reagendar cita: $e");
      throw Exception('Error al reagendar la cita: $e');
    }
  }
}