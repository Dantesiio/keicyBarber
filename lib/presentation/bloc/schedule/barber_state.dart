part of 'barber_bloc.dart';

abstract class BarberState {}

class BarberInitial extends BarberState {}

class BarberLoading extends BarberState {}

class BarberLoaded extends BarberState {
  final List<Barber> barbers;
  final String? selectedBarberId;

  BarberLoaded(this.barbers, {this.selectedBarberId});

  BarberLoaded copyWith({List<Barber>? barbers, String? selectedBarberId}) {
    return BarberLoaded(barbers ?? this.barbers, selectedBarberId: selectedBarberId ?? this.selectedBarberId);
  }
}

class BarberError extends BarberState {
  final String message;
  BarberError(this.message);
}
