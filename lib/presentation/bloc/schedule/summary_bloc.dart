import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/entities/appointment.dart';
import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/entities/location.dart';
import 'package:keicybarber/domain/entities/service.dart';
import 'package:keicybarber/domain/repositories/appointment_repository.dart';
import 'package:keicybarber/domain/repositories/barber_repository.dart';
import 'package:keicybarber/domain/repositories/location_repository.dart';
import 'package:keicybarber/domain/repositories/service_repository.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final ServiceRepository serviceRepository;
  final LocationRepository locationRepository;
  final BarberRepository barberRepository;
  final AppointmentRepository appointmentRepository;

  SummaryBloc({
    required this.serviceRepository,
    required this.locationRepository,
    required this.barberRepository,
    required this.appointmentRepository,
  }) : super(SummaryInitial()) {
    on<LoadSummaryDetails>(_onLoadSummaryDetails);
    on<ConfirmAppointmentEvent>(_onConfirmAppointment);
  }

  Future<void> _onLoadSummaryDetails(
    LoadSummaryDetails event,
    Emitter<SummaryState> emit,
  ) async {
    emit(SummaryLoading());
    try {
      final futureServices = serviceRepository.getServices();
      final futureLocations = locationRepository.getLocations();
      final futureBarbers =
          barberRepository.getBarbersByLocation(event.locationId);

      final results = await Future.wait([
        futureServices,
        futureLocations,
        futureBarbers,
      ]);

      final allServices = results[0] as List<Service>;
      final allLocations = results[1] as List<Location>;
      final allBarbers = results[2] as List<Barber>;

      final selectedServices =
          allServices.where((s) => event.serviceIds.contains(s.id)).toList();

      final location =
          allLocations.firstWhere((l) => l.id == event.locationId);

      final barber = allBarbers.firstWhere((b) => b.id == event.barberId);

      final totalPrice = selectedServices.fold<double>(
        0.0,
        (sum, service) => sum + service.price,
      );

      final totalDuration = selectedServices.fold<int>(
        0,
        (sum, service) => sum + service.durationMinutes,
      );

      emit(
        SummaryLoaded(
          selectedServices: selectedServices,
          location: location,
          barber: barber,
          totalPrice: totalPrice,
          totalDuration: totalDuration,
        ),
      );
    } catch (e) {
      emit(SummaryError('Error al cargar el resumen de la cita.'));
    }
  }

  Future<void> _onConfirmAppointment(
    ConfirmAppointmentEvent event,
    Emitter<SummaryState> emit,
  ) async {
    try {
      final current = state;

      if (current is! SummaryLoaded) {
        emit(SummaryError('No hay datos cargados para confirmar la cita.'));
        return;
      }

      emit(SummaryConfirmationLoading());

      final appointmentUTC = Appointment(
        id: event.appointment.id,
        serviceName: event.appointment.serviceName,
        dateTime: event.appointment.dateTime,
        barberName: event.appointment.barberName,
        location: event.appointment.location,
        price: event.appointment.price,
        status: event.appointment.status,
      );

      final userAppointments =
          await appointmentRepository.getAppointments();

      final conflict = userAppointments.any((appt) {
        return appt.dateTime.toLocal()
            .isAtSameMomentAs(event.appointment.dateTime.toLocal());
      });

      if (conflict) {
        emit(SummaryConflict(
            "Ya tienes una cita agendada exactamente a esa hora."));
        return;
      }

      final totalDurationMinutes = current.selectedServices.fold<int>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );

      final estimatedPriceCents = current.selectedServices.fold<int>(
        0,
        (sum, s) => sum + (s.price * 100).toInt(),
      );

      final serviceIds = current.selectedServices
          .map((s) => int.tryParse(s.id))
          .where((v) => v != null)
          .cast<int>()
          .toList();

      await appointmentRepository.createAppointment(
        appointment: appointmentUTC,
        serviceIds: serviceIds,
        barberId: current.barber.id,
        locationId: int.parse(current.location.id),
        totalDurationMinutes: totalDurationMinutes,
        estimatedPriceCents: estimatedPriceCents,
      );

      emit(SummaryConfirmationSuccess());
    } catch (e) {
      emit(SummaryError('No se pudo confirmar la cita: $e'));
    }
  }
}