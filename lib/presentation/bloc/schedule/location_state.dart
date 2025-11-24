part of 'location_bloc.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<Location> locations;
  final String? selectedLocationId;

  LocationLoaded(this.locations, {this.selectedLocationId});

  LocationLoaded copyWith({List<Location>? locations, String? selectedLocationId}) {
    return LocationLoaded(locations ?? this.locations, selectedLocationId: selectedLocationId ?? this.selectedLocationId);
  }
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}
