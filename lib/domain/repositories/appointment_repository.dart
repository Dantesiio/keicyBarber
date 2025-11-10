import '../entities/appointment.dart';
import 'package:flutter/material.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();

  Future<void> createAppointment({
    required Appointment appointment,
    required List<int> serviceIds,
    required String barberId,
    required int locationId,
    required int totalDurationMinutes,
    required int estimatedPriceCents,
  });

  Future<List<TimeOfDay>> getAvailableSlots({
    required String barberId,
    required int locationId,
    required DateTime day,
    required int requiredMinutes,
    int slotMinutes = 30,
  });
  
  Future<void> cancelAppointment(String id);
}
