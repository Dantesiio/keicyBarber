part of 'barber_bloc.dart';

abstract class BarberEvent {}

class LoadBarbersByLocation extends BarberEvent {
  final String locationId;
  LoadBarbersByLocation(this.locationId);
}

class SelectBarber extends BarberEvent {
  final String barberId;
  SelectBarber(this.barberId);
}
