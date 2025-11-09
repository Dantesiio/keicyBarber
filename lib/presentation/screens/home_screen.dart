import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_state.dart';
import '../bloc/navigation/navigation_cubit.dart';
import 'services_catalog_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // El Navigator anidado gestionará la pila de navegación para esta pestaña.
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            // La ruta inicial de este navegador es el contenido principal de Home.
            return const _HomeView();
          },
        );
      },
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFF2B705);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        Widget body;
        if (state is HomeLoaded) {
          body = _buildHomeContent(context, state.services);
        } else if (state is HomeError) {
          body = Center(child: Text('Error: ${state.message}'));
        } else {
          body = const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Column(
            children: [
              _buildHeader(),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF2B705),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Expanded(
            child: Text(
              '¡Hola, Juan!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          Text('250\nPuntos', textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<String> services) {
    final yellow = const Color(0xFFF2B705);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Próxima Cita',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Corte Y Barba',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          r'$45,000',
                          style: TextStyle(
                            color: Color(0xFFF2B705),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NavigationCubit>().setPage(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Agendar Nueva Cita'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Usamos el Navigator anidado para empujar la nueva pantalla.
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const ServicesCatalogScreen(),
                            ));
                          },
                          child: const Text('Ver Servicios'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Mi Historial'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nuestros Servicios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // Usamos ListView.shrinkWrap y physics para que funcione dentro de un SingleChildScrollView
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    services[index],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Incluye: Corte y masaje'),
                  trailing: const Icon(Icons.add),
                  onTap: () {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
