import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/appointments/appointments_bloc.dart';
import '../../domain/entities/appointment.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AppointmentsScreenState();
  }
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentsBloc(),
      child: const AppointmentsContent(),
    );
  }
}

class AppointmentsContent extends StatelessWidget {
  const AppointmentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);

    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      builder: (context, state) {
        // Carga inicial de datos
        if (state is AppointmentsInitialState) {
          print("Cargando citas inicialmente");
          context.read<AppointmentsBloc>().add(LoadAppointmentsEvent());
        }

        List<Appointment> filteredAppointments = [];
        if (state is AppointmentsLoadedState) {
          if (state.currentTab == 0) {
            // Próximas
            filteredAppointments = state.appointments
                .where((a) => a.status == 'Confirmada')
                .toList();
          } else if (state.currentTab == 1) {
            // Completadas
            filteredAppointments = state.appointments
                .where((a) => a.status == 'Completada')
                .toList();
          } else if (state.currentTab == 2) {
            // Canceladas
            filteredAppointments = state.appointments
                .where((a) => a.status == 'Cancelada')
                .toList();
          }
        }

        // Contar citas por estado
        int confirmadasCount = 0;
        int completadasCount = 0;
        int canceladasCount = 0;

        if (state is AppointmentsLoadedState) {
          confirmadasCount = state.appointments
              .where((a) => a.status == 'Confirmada')
              .length;
          completadasCount = state.appointments
              .where((a) => a.status == 'Completada')
              .length;
          canceladasCount = state.appointments
              .where((a) => a.status == 'Cancelada')
              .length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: yellow,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mis Citas',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gestiona tus citas agendadas',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Contadores
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CounterWidget(
                    count: confirmadasCount,
                    label: 'Confirmadas',
                    color: yellow,
                  ),
                  _CounterWidget(
                    count: completadasCount,
                    label: 'Completadas',
                    color: Colors.green,
                  ),
                  _CounterWidget(
                    count: canceladasCount,
                    label: 'Canceladas',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Próximas',
                    isActive: state.currentTab == 0,
                    badge: confirmadasCount > 0 ? '$confirmadasCount' : null,
                    onTap: () {
                      context.read<AppointmentsBloc>().add(
                        ChangeTabEvent(tabIndex: 0),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _TabButton(
                    label: 'Completadas',
                    isActive: state.currentTab == 1,
                    onTap: () {
                      context.read<AppointmentsBloc>().add(
                        ChangeTabEvent(tabIndex: 1),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _TabButton(
                    label: 'Canceladas',
                    isActive: state.currentTab == 2,
                    onTap: () {
                      context.read<AppointmentsBloc>().add(
                        ChangeTabEvent(tabIndex: 2),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Lista de citas
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state is AppointmentsLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AppointmentsErrorState) {
                    return Center(child: Text(state.message));
                  } else if (state is AppointmentsLoadedState) {
                    if (filteredAppointments.isEmpty) {
                      return _EmptyState(currentTab: state.currentTab);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        return _AppointmentCard(
                          appointment: appointment,
                          currentTab: state.currentTab,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CounterWidget extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CounterWidget({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final String? badge;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2B705),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final int currentTab;

  const _AppointmentCard({required this.appointment, required this.currentTab});

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('h:mm a');

    Color statusColor = yellow;
    if (appointment.status == 'Completada') {
      statusColor = Colors.green;
    } else if (appointment.status == 'Cancelada') {
      statusColor = Colors.red.shade100;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormatter.format(appointment.price),
              style: TextStyle(
                color: yellow,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 8),
                Text(dateFormatter.format(appointment.dateTime)),
                const SizedBox(width: 24),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(timeFormatter.format(appointment.dateTime)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 8),
                Text(appointment.barberName),
                const SizedBox(width: 24),
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 8),
                Text(appointment.location),
              ],
            ),
            if (currentTab == 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Falta reagendar
                        print("Reagendar cita ${appointment.id}");
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reagendar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showCancelDialog(context, appointment.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String appointmentId) {
    final yellow = const Color(0xFFF2B705);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cancelar Cita',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Está seguro que desea cancelar esta cita? Esta acción no se puede deshacer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AppointmentsBloc>().add(
                            CancelAppointmentEvent(
                              appointmentId: appointmentId,
                            ),
                          );
                          print("Cita cancelada: $appointmentId");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int currentTab;

  const _EmptyState({required this.currentTab});

  @override
  Widget build(BuildContext context) {
    String message = 'No has agendado ninguna cita';
    if (currentTab == 2) {
      message = 'No has cancelado ninguna cita';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin cancelaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
