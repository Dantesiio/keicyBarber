import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/repositories/barber_repository.dart';
import 'package:keicybarber/domain/repositories/appointment_repository.dart';
import 'package:flutter/material.dart';

part 'barber_event.dart';
part 'barber_state.dart';

class BarberBloc extends Bloc<BarberEvent, BarberState> {
  final BarberRepository barberRepository;
  final AppointmentRepository appointmentRepository;

  BarberBloc({required this.barberRepository, required this.appointmentRepository}) : super(BarberInitial()) {
    on<LoadBarbersByLocation>(_onLoadBarbersByLocation);
    on<SelectBarber>(_onSelectBarber);
    on<SelectBarberDate>(_onSelectBarberDate);
    on<SelectBarberTime>(_onSelectBarberTime);
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
      emit((state as BarberLoaded).copyWith(selectedBarberId: event.barberId, clearDate: true, clearTime: true));
    }
  }

  void _onSelectBarberDate(SelectBarberDate event, Emitter<BarberState> emit) async {
    if (state is! BarberLoaded) return;
    final curr = state as BarberLoaded;
    if (curr.selectedBarberId == null) {
      emit(curr.copyWith(
        selectedDate: DateTime(event.date.year, event.date.month, event.date.day),
        clearTime: true,
        clearSlots: true,
      ));
      return;
    }

    emit(curr.copyWith(
      selectedDate: DateTime(event.date.year, event.date.month, event.date.day),
      clearTime: true,
      clearSlots: true,
    ));

    try {
      // Consultar slots disponibles dinámicamente
      final slots = await appointmentRepository.getAvailableSlots(
        barberId: curr.selectedBarberId!,
        locationId: event.locationId,
        day: event.date,
        requiredMinutes: event.requiredMinutes,
        slotMinutes: 30,
      );

      emit((state as BarberLoaded).copyWith(availableSlots: slots));
    } catch (e) {
      emit((state as BarberLoaded).copyWith(availableSlots: const []));
    }
  }

  void _onSelectBarberTime(SelectBarberTime event, Emitter<BarberState> emit) {
    if (state is BarberLoaded) {
      emit((state as BarberLoaded).copyWith(selectedTime: event.time));
    }
  }
}