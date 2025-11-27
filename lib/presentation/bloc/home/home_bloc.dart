import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../domain/entities/appointment.dart';
import '../../../../domain/usecases/get_next_appointment.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../../domain/usecases/get_services.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetServices getServices;
  final GetNextAppointment getNextAppointment;

  HomeBloc({
    required this.getServices,
    required this.getNextAppointment,
  }) : super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<NavigateToService>(_onNavigateToService);
  }

  void _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final services = await getServices();
      final serviceNames = services.map((s) => s.name).toList();
      final nextAppointment = await _fetchNextAppointment();
      emit(HomeLoaded(
        serviceNames,
        nextAppointment: nextAppointment,
      ));
    } catch (e) {
      emit(HomeError('Error al cargar servicios'));
    }
  }

  void _onNavigateToService(NavigateToService event, Emitter<HomeState> emit) {
    // Lógica para navegar a servicio, por ahora solo registrar en log
    developer.log(
      'Navegando al servicio: ${event.serviceId}',
      name: 'HomeBloc',
    );
  }

  Future<Appointment?> _fetchNextAppointment() async {
    try {
      return await getNextAppointment();
    } catch (e, stackTrace) {
      developer.log(
        'Error al obtener la próxima cita',
        name: 'HomeBloc',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
