import 'package:flutter/material.dart';

abstract class RescheduleEvent {}

class InitRescheduleEvent extends RescheduleEvent {
  // Opcional: Para inicializar datos si fuera necesario
}

class SelectRescheduleDateEvent extends RescheduleEvent {
  final DateTime date;
  final String barberId;
  final int locationId;
  final int durationMinutes;

  SelectRescheduleDateEvent({
    required this.date,
    required this.barberId,
    required this.locationId,
    required this.durationMinutes,
  });
}

class SelectRescheduleTimeEvent extends RescheduleEvent {
  final TimeOfDay time;
  SelectRescheduleTimeEvent(this.time);
}

class ConfirmRescheduleEvent extends RescheduleEvent {
  final String appointmentId;
  final DateTime date;
  final TimeOfDay time;
  final int durationMinutes;

  ConfirmRescheduleEvent({
    required this.appointmentId,
    required this.date,
    required this.time,
    required this.durationMinutes,
  });
}
