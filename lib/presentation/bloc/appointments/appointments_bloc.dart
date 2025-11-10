import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/get_appointments.dart';

// Events
abstract class AppointmentsEvent {}

class LoadAppointmentsEvent extends AppointmentsEvent {}

class CancelAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;
  CancelAppointmentEvent({required this.appointmentId});
}

class ChangeTabEvent extends AppointmentsEvent {
  final int tabIndex;
  ChangeTabEvent({required this.tabIndex});
}

// States
abstract class AppointmentsState {
  final List<Appointment> appointments;
  final int currentTab;

  AppointmentsState({this.appointments = const [], this.currentTab = 0});
}

class AppointmentsInitialState extends AppointmentsState {}

class AppointmentsLoadingState extends AppointmentsState {
  AppointmentsLoadingState({super.appointments, super.currentTab});
}

class AppointmentsLoadedState extends AppointmentsState {
  AppointmentsLoadedState({required super.appointments, super.currentTab});
}

class AppointmentsErrorState extends AppointmentsState {
  final String message;

  AppointmentsErrorState({
    required this.message,
    super.appointments,
    super.currentTab,
  });
}

// Bloc
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final GetAppointments _getAppointments = GetAppointments();

  AppointmentsBloc() : super(AppointmentsInitialState()) {
    on<LoadAppointmentsEvent>(_onLoadAppointments);
    on<CancelAppointmentEvent>(_onCancelAppointment);
    on<ChangeTabEvent>(_onChangeTab);
  }

  Future<void> _onLoadAppointments(
    LoadAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(
      AppointmentsLoadingState(
        appointments: state.appointments,
        currentTab: state.currentTab,
      ),
    );
    try {
      final appointments = await _getAppointments.execute();
      emit(
        AppointmentsLoadedState(
          appointments: appointments,
          currentTab: state.currentTab,
        ),
      );
    } catch (e) {
      print("❌ Error al cargar citas: $e");
      emit(
        AppointmentsErrorState(
          message: 'Error al cargar citas',
          appointments: state.appointments,
          currentTab: state.currentTab,
        ),
      );
    }
  }

  Future<void> _onCancelAppointment(
    CancelAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    try {
      await _getAppointments.repository.cancelAppointment(event.appointmentId);
      final appointments = await _getAppointments.execute();
      emit(
        AppointmentsLoadedState(
          appointments: appointments,
          currentTab: state.currentTab,
        ),
      );
    } catch (e) {
      print("❌ Error al cancelar cita: $e");
      emit(
        AppointmentsErrorState(
          message: 'Error al cancelar cita: $e',
          appointments: state.appointments,
          currentTab: state.currentTab,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      try {
        final appointments = await _getAppointments.execute();
        emit(
          AppointmentsLoadedState(
            appointments: appointments,
            currentTab: state.currentTab,
          ),
        );
      } catch (e2) {
        print("❌ Error al recargar citas: $e2");
      }
    }
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<AppointmentsState> emit) {
    if (state is AppointmentsLoadedState) {
      emit(
        AppointmentsLoadedState(
          appointments: state.appointments,
          currentTab: event.tabIndex,
        ),
      );
    }
  }
}
