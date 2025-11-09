import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/repositories/barber_repository.dart';

part 'barber_event.dart';
part 'barber_state.dart';

class BarberBloc extends Bloc<BarberEvent, BarberState> {
  final BarberRepository barberRepository;

  BarberBloc({required this.barberRepository}) : super(BarberInitial()) {
    on<LoadBarbersByLocation>(_onLoadBarbersByLocation);
    on<SelectBarber>(_onSelectBarber);
  }

  void _onLoadBarbersByLocation(LoadBarbersByLocation event, Emitter<BarberState> emit) async {
    emit(BarberLoading());
    try {
      final barbers = await barberRepository.getBarbersByLocation(event.locationId);
      emit(BarberLoaded(barbers));
    } catch (e) {
      emit(BarberError('Error al cargar los barberos'));
    }
  }

  void _onSelectBarber(SelectBarber event, Emitter<BarberState> emit) {
    if (state is BarberLoaded) {
      emit((state as BarberLoaded).copyWith(selectedBarberId: event.barberId));
    }
  }
}
