part of 'summary_bloc.dart';

abstract class SummaryEvent {}

class LoadSummaryDetails extends SummaryEvent {
  final Set<String> serviceIds;
  final String locationId;
  final String barberId;

  LoadSummaryDetails({required this.serviceIds, required this.locationId, required this.barberId});
}

class ConfirmAppointmentEvent extends SummaryEvent {
  final Appointment appointment;

  ConfirmAppointmentEvent(this.appointment);
}
