part of 'schedule_bloc.dart';

abstract class ScheduleEvent {}

class LoadServices extends ScheduleEvent {}

class ToggleServiceSelection extends ScheduleEvent {
  final String serviceId;
  ToggleServiceSelection(this.serviceId);
}