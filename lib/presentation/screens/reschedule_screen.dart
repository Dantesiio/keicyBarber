import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keicybarber/data/repositories/appointment_repository_impl.dart';
import 'package:keicybarber/domain/entities/appointment.dart';
import 'package:keicybarber/presentation/bloc/reschedule/reschedule_bloc.dart';
import 'package:keicybarber/presentation/bloc/reschedule/reschedule_event.dart';
import 'package:keicybarber/presentation/bloc/reschedule/reschedule_state.dart';

class RescheduleScreen extends StatelessWidget {
  final Appointment appointment;

  const RescheduleScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RescheduleBloc(appointmentRepository: AppointmentRepositoryImpl()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reagendar Cita'),
          backgroundColor: const Color(0xFFF2B705),
          elevation: 0,
        ),
        body: BlocListener<RescheduleBloc, RescheduleState>(
          listener: (context, state) {
            if (state is RescheduleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Cita reagendada con éxito!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Regresamos 2 veces o a la raíz, dependiendo del flujo.
              // Aquí regresamos a la pantalla de citas y forzamos recarga si es necesario.
              Navigator.of(context).pop(true);
            } else if (state is RescheduleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: _RescheduleView(appointment: appointment),
        ),
      ),
    );
  }
}

class _RescheduleView extends StatefulWidget {
  final Appointment appointment;

  const _RescheduleView({required this.appointment});

  @override
  State<_RescheduleView> createState() => _RescheduleViewState();
}

class _RescheduleViewState extends State<_RescheduleView> {
  // Generador de próximos días
  List<DateTime> _nextDays({int count = 14}) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final d = now.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  String _capFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);
    final days = _nextDays();
    final dateFormatter = DateFormat('EEEE d MMMM', 'es_CO');

    // NOTA: Asegúrate de que tu entidad Appointment tenga estos campos mapeados
    // Si no los tienes en la entidad, deberás ajustar esto.
    final barberId = widget.appointment.barberId;
    final locationId = widget.appointment.locationId;
    final duration = widget.appointment.durationMinutes;

    return Column(
      children: [
        // Resumen de la cita actual
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.appointment.serviceName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 6),
                  Text(widget.appointment.barberName),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 6),
                  Text('$duration min • Reagendando'),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<RescheduleBloc, RescheduleState>(
              builder: (context, state) {
                DateTime? selectedDate;
                TimeOfDay? selectedTime;
                List<TimeOfDay> slots = [];

                if (state is RescheduleLoadingSlots) {
                  selectedDate = state.selectedDate;
                } else if (state is RescheduleSlotsLoaded) {
                  selectedDate = state.selectedDate;
                  slots = state.availableSlots;
                  selectedTime = state.selectedTime;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona nueva fecha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Selector de Fechas (Scroll Horizontal)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: days.map((d) {
                          final isSelected =
                              selectedDate != null &&
                              d.year == selectedDate!.year &&
                              d.month == selectedDate!.month &&
                              d.day == selectedDate!.day;

                          final dayName = DateFormat('EEE', 'es_CO').format(d);
                          final dayNum = d.day.toString();

                          return GestureDetector(
                            onTap: () {
                              context.read<RescheduleBloc>().add(
                                SelectRescheduleDateEvent(
                                  date: d,
                                  barberId:
                                      barberId, // Asegúrate que tu Appointment tenga este campo
                                  locationId:
                                      locationId, // Asegúrate que tu Appointment tenga este campo
                                  durationMinutes: duration,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _capFirst(dayName),
                                    style: TextStyle(
                                      color: isSelected
                                          ? yellow
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayNum,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Selector de Horas
                    if (selectedDate != null) ...[
                      Text(
                        'Horarios disponibles para ${_capFirst(dateFormatter.format(selectedDate!))}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (state is RescheduleLoadingSlots)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (slots.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No hay horarios disponibles para esta fecha.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: slots.map((time) {
                            final isSelected = selectedTime == time;
                            return ChoiceChip(
                              label: Text(time.format(context)),
                              selected: isSelected,
                              onSelected: (_) {
                                context.read<RescheduleBloc>().add(
                                  SelectRescheduleTimeEvent(time),
                                );
                              },
                              selectedColor: yellow,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? yellow
                                      : Colors.grey.shade300,
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Selecciona una fecha para ver los horarios.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),

        // Botón Confirmar
        BlocBuilder<RescheduleBloc, RescheduleState>(
          builder: (context, state) {
            bool canConfirm = false;
            if (state is RescheduleSlotsLoaded && state.selectedTime != null) {
              canConfirm = true;
            }
            if (state is RescheduleProcessing) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canConfirm
                      ? () {
                          final loadedState = state as RescheduleSlotsLoaded;
                          context.read<RescheduleBloc>().add(
                            ConfirmRescheduleEvent(
                              appointmentId: widget.appointment.id
                                  .toString(), // o widget.appointment.id si es string
                              date: loadedState.selectedDate,
                              time: loadedState.selectedTime!,
                              durationMinutes: duration,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirmar Nuevo Horario',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
