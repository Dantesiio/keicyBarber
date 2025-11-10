part of 'barber_bloc.dart';

abstract class BarberState {}

class BarberInitial extends BarberState {}

class BarberLoading extends BarberState {}

class BarberLoaded extends BarberState {
  final List<Barber> barbers;
  final String? selectedBarberId;

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  final List<TimeOfDay> availableSlots;

  BarberLoaded(this.barbers, {this.selectedBarberId,this.selectedDate,this.selectedTime,this.availableSlots = const [],});

  BarberLoaded copyWith({
    List<Barber>? barbers,
    String? selectedBarberId,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    List<TimeOfDay>? availableSlots,
    bool clearDate = false,
    bool clearTime = false,
    bool clearSlots = false,
  }) {
    return BarberLoaded(
      barbers ?? this.barbers,
      selectedBarberId: selectedBarberId ?? this.selectedBarberId,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedTime: clearTime ? null : (selectedTime ?? this.selectedTime),
      availableSlots: clearSlots ? const [] : (availableSlots ?? this.availableSlots),
    );
  }
}

class BarberError extends BarberState {
  final String message;
  BarberError(this.message);
}