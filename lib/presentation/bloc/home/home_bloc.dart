import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'home_event.dart';
import 'home_state.dart';
import '../../../domain/usecases/get_services.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetServices getServices;

  HomeBloc({required this.getServices}) : super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<NavigateToService>(_onNavigateToService);
  }

  void _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final services = await getServices();
      final serviceNames = services.map((s) => s.name).toList();
      emit(HomeLoaded(serviceNames));
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
}