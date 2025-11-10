import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/usecases/get_locations.dart';
import 'package:keicybarber/data/repositories/location_repository_impl.dart';
import 'package:keicybarber/presentation/bloc/schedule/location_bloc.dart';
import 'package:keicybarber/presentation/screens/schedule_barber_screen.dart';

class ScheduleLocationScreen extends StatelessWidget {
  final Set<String> selectedServiceIds;

  const ScheduleLocationScreen({
    super.key,
    required this.selectedServiceIds,
  });

  @override
  Widget build(BuildContext context) {
    // Idealmente, esto se inyectaría con get_it o un provider de más alto nivel
    // NOTA: El usecase GetLocations ya no es necesario aquí, el BLoC lo manejará.
    final getLocations = GetLocations(LocationRepositoryImpl());

    return BlocProvider(
      create: (context) => LocationBloc(getLocations: getLocations)..add(LoadLocations()),
      child: Scaffold(
        // Usamos un Scaffold para tener un AppBar y un fondo consistente
        appBar: AppBar(backgroundColor: const Color(0xFFF2B705), elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
        body: _ScheduleLocationView(selectedServiceIds: selectedServiceIds),
      ),
    );
  }
}

class _ScheduleLocationView extends StatelessWidget {
  final Set<String> selectedServiceIds;

  const _ScheduleLocationView({required this.selectedServiceIds});

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
                  'Selecciona la sede',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8),
              Text('Paso 2 de 4'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state is LocationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is LocationError) {
                return Center(child: Text(state.message));
              }
              if (state is LocationLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.locations.length,
                  itemBuilder: (context, index) {
                    final location = state.locations[index];
                    final isSelected = state.selectedLocationId == location.id;

                    return GestureDetector(
                      onTap: () {
                        context.read<LocationBloc>().add(SelectLocation(location.id));
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? yellow : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(                          
                          isThreeLine: true,
                          title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(location.address),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: yellow)
                              : const Icon(Icons.circle_outlined),
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
        BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationLoaded && state.selectedLocationId != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ScheduleBarberScreen(
                        selectedServiceIds: selectedServiceIds,
                        selectedLocationId: state.selectedLocationId!,
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