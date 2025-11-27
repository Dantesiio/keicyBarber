import 'package:equatable/equatable.dart';
import '../../../../domain/entities/appointment.dart';
import '../../../../domain/entities/service.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Service> services;
  final Appointment? nextAppointment;

  const HomeLoaded({
    required this.services,
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
