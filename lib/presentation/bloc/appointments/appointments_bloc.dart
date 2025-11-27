import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/get_appointments.dart';
import '../../../domain/repositories/appointment_repository.dart';

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

abstract class AppointmentsState {
  final List<Appointment> appointments;
  final int currentTab;

  AppointmentsState({
    this.appointments = const [],
    this.currentTab = 0,
  });
}

class AppointmentsInitialState extends AppointmentsState {}

class AppointmentsLoadingState extends AppointmentsState {
  AppointmentsLoadingState({
    super.appointments,
    super.currentTab,
  });
}

class AppointmentsLoadedState extends AppointmentsState {
  AppointmentsLoadedState({
    required super.appointments,
    super.currentTab,
  });
}

class AppointmentsErrorState extends AppointmentsState {
  final String message;

  AppointmentsErrorState({
    required this.message,
    super.appointments,
    super.currentTab,
  });
}

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final GetAppointments getAppointments;
  final AppointmentRepository appointmentRepository;

  AppointmentsBloc({
    required this.getAppointments,
    required this.appointmentRepository,
  }) : super(AppointmentsInitialState()) {
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
      final appointments = await getAppointments.execute();
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
      await appointmentRepository.cancelAppointment(event.appointmentId);

      final appointments = await getAppointments.execute();

      emit(
        AppointmentsLoadedState(
          appointments: appointments,
          currentTab: state.currentTab,
        ),
      );
    } catch (e) {
      emit(
        AppointmentsErrorState(
          message: 'Error al cancelar cita: $e',
          appointments: state.appointments,
          currentTab: state.currentTab,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      try {
        final appointments = await getAppointments.execute();

        emit(
          AppointmentsLoadedState(
            appointments: appointments,
            currentTab: state.currentTab,
          ),
        );
      } catch (_) {}
    }
  }

  void _onChangeTab(
      ChangeTabEvent event, Emitter<AppointmentsState> emit) {
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