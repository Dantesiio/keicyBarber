import 'package:equatable/equatable.dart';
import '../../../../domain/entities/appointment.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<String> services;
  final Appointment? nextAppointment;

  const HomeLoaded(
    this.services, {
    this.nextAppointment,
  });

  @override
  List<Object?> get props => [services, nextAppointment];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
