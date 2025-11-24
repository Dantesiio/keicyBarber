part of 'summary_bloc.dart';

abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final List<Service> selectedServices;
  final Location location;
  final Barber barber;
  final double totalPrice;
  final int totalDuration;

  SummaryLoaded({
    required this.selectedServices,
    required this.location,
    required this.barber,
    required this.totalPrice,
    required this.totalDuration,
  });
}

class SummaryError extends SummaryState {
  final String message;
  SummaryError(this.message);
}

class SummaryConfirmationSuccess extends SummaryState {}
class SummaryConfirmationLoading extends SummaryState {}
