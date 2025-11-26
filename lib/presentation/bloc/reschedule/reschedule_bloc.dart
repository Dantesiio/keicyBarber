import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/repositories/appointment_repository.dart';
import 'reschedule_event.dart';
import 'reschedule_state.dart';

class RescheduleBloc extends Bloc<RescheduleEvent, RescheduleState> {
  final AppointmentRepository appointmentRepository;

  RescheduleBloc({required this.appointmentRepository})
    : super(RescheduleInitial()) {
    on<SelectRescheduleDateEvent>(_onSelectDate);
    on<SelectRescheduleTimeEvent>(_onSelectTime);
    on<ConfirmRescheduleEvent>(_onConfirmReschedule);
  }

  Future<void> _onSelectDate(
    SelectRescheduleDateEvent event,
    Emitter<RescheduleState> emit,
  ) async {
    emit(RescheduleLoadingSlots(event.date));

    try {
      final slots = await appointmentRepository.getAvailableSlots(
        barberId: event.barberId,
        locationId: event.locationId,
        day: event.date,
        requiredMinutes: event.durationMinutes,
      );

      emit(
        RescheduleSlotsLoaded(
          selectedDate: event.date,
          availableSlots: slots,
          selectedTime: null, // Reiniciamos la hora al cambiar de fecha
        ),
      );
    } catch (e) {
      emit(RescheduleError('Error al cargar horarios: $e'));
    }
  }

  void _onSelectTime(
    SelectRescheduleTimeEvent event,
    Emitter<RescheduleState> emit,
  ) {
    if (state is RescheduleSlotsLoaded) {
      final currentState = state as RescheduleSlotsLoaded;
      emit(currentState.copyWith(selectedTime: event.time));
    }
  }

  Future<void> _onConfirmReschedule(
    ConfirmRescheduleEvent event,
    Emitter<RescheduleState> emit,
  ) async {
    emit(RescheduleProcessing());

    try {
      // Combinar Fecha y Hora seleccionada
      final newDateTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.time.hour,
        event.time.minute,
      );

      await appointmentRepository.rescheduleAppointment(
        appointmentId: event.appointmentId,
        newStartTime: newDateTime,
        durationMinutes: event.durationMinutes,
      );

      emit(RescheduleSuccess());
    } catch (e) {
      emit(RescheduleError('No se pudo reagendar: $e'));
    }
  }
}
