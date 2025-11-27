import 'package:flutter/material.dart';

abstract class RescheduleState {}

class RescheduleInitial extends RescheduleState {}

class RescheduleLoadingSlots extends RescheduleState {
  // Mantenemos la fecha seleccionada para mostrarla activa en la UI
  final DateTime selectedDate;
  RescheduleLoadingSlots(this.selectedDate);
}

class RescheduleSlotsLoaded extends RescheduleState {
  final DateTime selectedDate;
  final List<TimeOfDay> availableSlots;
  final TimeOfDay? selectedTime;

  RescheduleSlotsLoaded({
    required this.selectedDate,
    required this.availableSlots,
    this.selectedTime,
  });

  RescheduleSlotsLoaded copyWith({
    DateTime? selectedDate,
    List<TimeOfDay>? availableSlots,
    TimeOfDay? selectedTime,
  }) {
    return RescheduleSlotsLoaded(
      selectedDate: selectedDate ?? this.selectedDate,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

class RescheduleProcessing extends RescheduleState {}

class RescheduleSuccess extends RescheduleState {}

class RescheduleError extends RescheduleState {
  final String message;
  RescheduleError(this.message);
}
