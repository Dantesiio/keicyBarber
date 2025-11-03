part of 'barber_bloc.dart';

abstract class BarberState {}

class BarberInitial extends BarberState {}

class BarberLoading extends BarberState {}

class BarberLoaded extends BarberState {
  final List<Barber> barbers;
  final String? selectedBarberId;

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  BarberLoaded(this.barbers, {this.selectedBarberId, this.selectedDate, this.selectedTime});

  BarberLoaded copyWith({List<Barber>? barbers, String? selectedBarberId, DateTime? selectedDate, TimeOfDay? selectedTime, bool clearDate = false, bool clearTime = false}) {
    return BarberLoaded(barbers ?? this.barbers, selectedBarberId: selectedBarberId ?? this.selectedBarberId, selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),selectedTime: clearTime ? null : (selectedTime ?? this.selectedTime));
  }
}

class BarberError extends BarberState {
  final String message;
  BarberError(this.message);
}