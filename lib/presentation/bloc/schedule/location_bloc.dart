import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/entities/location.dart';
import 'package:keicybarber/domain/usecases/get_locations.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetLocations getLocations;

  LocationBloc({required this.getLocations}) : super(LocationInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<SelectLocation>(_onSelectLocation);
  }

  void _onLoadLocations(LoadLocations event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final locations = await getLocations();
      emit(LocationLoaded(locations));
    } catch (e) {
      emit(LocationError('Error al cargar las sedes'));
    }
  }

  void _onSelectLocation(SelectLocation event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      emit((state as LocationLoaded).copyWith(selectedLocationId: event.locationId));
    }
  }
}
