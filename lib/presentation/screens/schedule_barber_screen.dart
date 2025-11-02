import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/data/repositories/barber_repository_impl.dart';
import 'package:keicybarber/presentation/bloc/schedule/barber_bloc.dart';
import 'package:keicybarber/presentation/screens/schedule_summary_screen.dart';

class ScheduleBarberScreen extends StatelessWidget {
  final Set<String> selectedServiceIds;
  final String selectedLocationId;

  const ScheduleBarberScreen({
    super.key,
    required this.selectedServiceIds,
    required this.selectedLocationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BarberBloc(barberRepository: BarberRepositoryImpl())
        ..add(LoadBarbersByLocation(selectedLocationId)),
      child: Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFFF2B705), elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
        body: _ScheduleBarberView(selectedServiceIds: selectedServiceIds, selectedLocationId: selectedLocationId),
      ),
    );
  }
}

class _ScheduleBarberView extends StatelessWidget {
  final Set<String> selectedServiceIds;
  final String selectedLocationId;
  
  const _ScheduleBarberView({required this.selectedServiceIds, required this.selectedLocationId});

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header ---
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
                  'Elige tu barbero',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8),
              Text('Paso 3 de 4'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<BarberBloc, BarberState>(
            builder: (context, state) {
              if (state is BarberLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is BarberError) {
                return Center(child: Text(state.message));
              }
              if (state is BarberLoaded) {
                if (state.barbers.isEmpty) {
                  return const Center(child: Text('No hay barberos disponibles en esta sede.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.barbers.length,
                  itemBuilder: (context, index) {
                    final barber = state.barbers[index];
                    final isSelected = state.selectedBarberId == barber.id;

                    return GestureDetector(
                      onTap: () => context.read<BarberBloc>().add(SelectBarber(barber.id)),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSelected ? yellow : Colors.transparent, width: 2),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(barber.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(barber.specialtys.join(', ')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(barber.rating.toString()),
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
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
        // --- Botón para continuar ---
        BlocBuilder<BarberBloc, BarberState>(
          builder: (context, state) {
            if (state is BarberLoaded && state.selectedBarberId != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ScheduleSummaryScreen(
                        selectedServiceIds: selectedServiceIds,
                        selectedLocationId: selectedLocationId,
                        selectedBarberId: state.selectedBarberId!,
                      ),
                    ));
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
