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

class SelectBarberDate extends BarberEvent {
  final DateTime date;
  SelectBarberDate(this.date);
}

class SelectBarberTime extends BarberEvent {
  final TimeOfDay time;
  SelectBarberTime(this.time);
}