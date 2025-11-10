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
  final int requiredMinutes;
  final int locationId;
  SelectBarberDate(this.date, {required this.requiredMinutes, required this.locationId});
}

class SelectBarberTime extends BarberEvent {
  final TimeOfDay time;
  SelectBarberTime(this.time);
}