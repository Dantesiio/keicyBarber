part of 'location_bloc.dart';

abstract class LocationEvent {}

class LoadLocations extends LocationEvent {}

class SelectLocation extends LocationEvent {
  final String locationId;

  SelectLocation(this.locationId);
}
