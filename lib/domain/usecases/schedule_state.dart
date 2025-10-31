part of 'schedule_bloc.dart';

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Service> services;
  final Set<String> selectedServiceIds;

  ScheduleLoaded(this.services, {this.selectedServiceIds = const {}});

  ScheduleLoaded copyWith({
    List<Service>? services,
    Set<String>? selectedServiceIds,
  }) {
    return ScheduleLoaded(
      services ?? this.services,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
    );
  }
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}