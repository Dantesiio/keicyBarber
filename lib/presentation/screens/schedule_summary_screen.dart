import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keicybarber/data/repositories/appointment_repository_impl.dart';
import 'package:keicybarber/data/repositories/barber_repository_impl.dart';
import 'package:keicybarber/data/repositories/location_repository_impl.dart';
import 'package:keicybarber/data/repositories/service_repository_impl.dart';
import 'package:keicybarber/domain/entities/appointment.dart';
import 'package:keicybarber/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:keicybarber/presentation/bloc/schedule/summary_bloc.dart';

class ScheduleSummaryScreen extends StatelessWidget {
  final Set<String> selectedServiceIds;
  final String selectedLocationId;
  final String selectedBarberId;
  final DateTime selectedDateTime;

  const ScheduleSummaryScreen({
    super.key,
    required this.selectedServiceIds,
    required this.selectedLocationId,
    required this.selectedBarberId,
    required this.selectedDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SummaryBloc(
        serviceRepository: ServiceRepositoryImpl(),
        locationRepository: LocationRepositoryImpl(),
        barberRepository: BarberRepositoryImpl(),
        appointmentRepository: AppointmentRepositoryImpl(),
      )..add(LoadSummaryDetails(
          serviceIds: selectedServiceIds,
          locationId: selectedLocationId,
          barberId: selectedBarberId,
        )),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2B705),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: _ScheduleSummaryView(selectedDateTime: selectedDateTime),
      ),
    );
  }
}

class _ScheduleSummaryView extends StatelessWidget {
  const _ScheduleSummaryView({required this.selectedDateTime});
  final DateTime selectedDateTime;

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    final dateLong =
        _capitalize(DateFormat("EEEE d 'de' MMMM y", 'es_CO').format(selectedDateTime));
    final timeStr = DateFormat('h:mm a', 'es_CO').format(selectedDateTime);

    return BlocConsumer<SummaryBloc, SummaryState>(
      listener: (context, state) {
        if (state is SummaryConfirmationSuccess) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          context.read<NavigationCubit>().setPage(2);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cita confirmada con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SummaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SummaryError) {
          return Center(child: Text(state.message));
        }
        if (state is SummaryLoaded) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: yellow,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        'Confirma tu cita',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Paso 4 de 4'),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resumen de tu cita',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),

                          // Servicios + total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Servicios:',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                currencyFormatter.format(state.totalPrice),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: state.selectedServices.map((s) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(s.name,
                                        style: const TextStyle(
                                            color: Colors.black87)),
                                    Text(
                                      currencyFormatter.format(s.price),
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          const Divider(),

                          // Duración total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Duración total:',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('${state.totalDuration} min',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Resumen
                          _summaryRow('Barbero:', state.barber.name),
                          _summaryRow('Sede:', state.location.name),
                          _summaryRow('', state.location.address),
                          _summaryRow('', state.location.number),
                          _summaryRow('Fecha y hora:', '$dateLong\n$timeStr'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Confirmar
              if (state is! SummaryConfirmationLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final newAppointment = Appointment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        serviceName: state.selectedServices.map((s) => s.name).join(', '),
                        dateTime: selectedDateTime,
                        barberName: state.barber.name,
                        location: state.location.name,
                        price: state.totalPrice,
                        status: 'Confirmada',
                      );
                      context.read<SummaryBloc>().add(ConfirmAppointmentEvent(newAppointment));
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Confirmar Cita'),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}