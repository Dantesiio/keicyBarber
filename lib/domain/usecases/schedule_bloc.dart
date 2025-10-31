import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/service.dart';
import '../../../domain/usecases/get_services.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetServices getServices;

  ScheduleBloc({required this.getServices}) : super(ScheduleInitial()) {
    on<LoadServices>(_onLoadServices);
    on<ToggleServiceSelection>(_onToggleServiceSelection);
  }

  void _onLoadServices(LoadServices event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final services = await getServices();
      emit(ScheduleLoaded(services));
    } catch (e) {
      emit(ScheduleError('Error al cargar los servicios'));
    }
  }

  void _onToggleServiceSelection(ToggleServiceSelection event, Emitter<ScheduleState> emit) {
    final currentState = state;
    if (currentState is ScheduleLoaded) {
      final currentSelection = currentState.selectedServiceIds;
      final newSelection = Set<String>.from(currentSelection);

      if (newSelection.contains(event.serviceId)) {
        newSelection.remove(event.serviceId);
      } else {
        newSelection.add(event.serviceId);
      }

      emit(currentState.copyWith(selectedServiceIds: newSelection));
    }
  }
}