import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHome extends HomeEvent {}

class NavigateToService extends HomeEvent {
  final String serviceId;

  const NavigateToService(this.serviceId);

  @override
  List<Object> get props => [serviceId];
}
