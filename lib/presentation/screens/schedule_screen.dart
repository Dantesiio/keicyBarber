import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keicybarber/domain/usecases/schedule_bloc.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/usecases/get_services.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final getServices = GetServices(ServiceRepositoryImpl());

    return BlocProvider(
      create: (context) => ScheduleBloc(getServices: getServices)..add(LoadServices()),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  'Selecciona tu servicio',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8),
              Text('Paso 1 de 4'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Resumen de servicios seleccionados
        BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoaded && state.selectedServiceIds.isNotEmpty) {
              final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
              final selectedServices = state.services.where((s) => state.selectedServiceIds.contains(s.id)).toList();
              final totalPrice = selectedServices.fold(0.0, (sum, service) => sum + service.price);

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...selectedServices.map((service) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(service.name),
                                  Text(currencyFormatter.format(service.price)),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(
                              currencyFormatter.format(totalPrice),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: yellow),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: BlocBuilder<ScheduleBloc, ScheduleState>(
            builder: (context, state) {
              if (state is ScheduleLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ScheduleError) {
                return Center(child: Text(state.message));
              }
              if (state is ScheduleLoaded) {
                final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.services.length,
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    final isSelected = state.selectedServiceIds.contains(service.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? yellow : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule, size: 14),
                                        const SizedBox(width: 6),
                                        Text('${service.durationMinutes} min', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currencyFormatter.format(service.price),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              service.description,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ScheduleBloc>().add(ToggleServiceSelection(service.id));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? yellow : Colors.white,
                                foregroundColor: isSelected ? Colors.black : Colors.black,
                                side: BorderSide(
                                  color: isSelected ? yellow : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(isSelected ? '✓ Agregado' : '+ Agregar servicio'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        // Botón para continuar
        BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoaded && state.selectedServiceIds.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navegar a la siguiente pantalla (F5: Selección de Sede)
                    // Puedes acceder a los servicios seleccionados con: state.selectedServiceIds
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: yellow, foregroundColor: Colors.black),
                  child: const Text('Continuar'),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
