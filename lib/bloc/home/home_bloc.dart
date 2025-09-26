import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<NavigateToService>(_onNavigateToService);
  }

  void _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Simular carga de servicios (en el futuro, desde backend)
      await Future.delayed(const Duration(seconds: 1));
      final services = ['Corte de cabello', 'Barba', 'Tinte', 'Masaje'];
      emit(HomeLoaded(services));
    } catch (e) {
      emit(HomeError('Error al cargar servicios'));
    }
  }

  void _onNavigateToService(NavigateToService event, Emitter<HomeState> emit) {
    // Lógica para navegar a servicio, por ahora solo imprimir
    print('Navegando al servicio: ${event.serviceId}');
  }
}
