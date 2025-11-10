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
      // Actualizar el estado de la cita
      final updatedAppointments = state.appointments.map((appointment) {
        if (appointment.id == event.appointmentId) {
          return Appointment(
            id: appointment.id,
            serviceName: appointment.serviceName,
            dateTime: appointment.dateTime,
            barberName: appointment.barberName,
            location: appointment.location,
            price: appointment.price,
            status: 'Cancelada',
          );
        }
        return appointment;
      }).toList();

      emit(
        AppointmentsLoadedState(
          appointments: updatedAppointments,
          currentTab: state.currentTab,
        ),
      );
    } catch (e) {
      emit(
        AppointmentsErrorState(
          message: 'Error al cancelar cita',
          appointments: state.appointments,
          currentTab: state.currentTab,
        ),
      );
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
