import 'package:keicybarber/domain/entities/service.dart';
import 'package:keicybarber/domain/repositories/service_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<Service>> getServices() async {
    try {
      // Hacemos la consulta a la tabla 'services' y la unimos con 'barber_services'.
      // 'barber_services!inner(*)' asegura que solo se traigan servicios que
      // tengan al menos una entrada en la tabla de relación.
      final response = await _supabaseClient
          .from('services')
          .select('*, barber_services!inner(*)')
          .eq('status', 'activo');
      // Creamos una nueva lista con el tipo correcto para satisfacer al compilador web.
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Mapeamos la respuesta (una lista de mapas) a una lista de objetos Service
      final services = data.map((item) {
        return Service(
          id: item['id'].toString(),
          name: item['name'],
          description: item['description'],
          durationMinutes: item['duration_minutes'],
          price: (item['price_cents'] as int) / 100.0,
        );
      }).toList();

      return services;
    } catch (e) {
      // Manejo de errores básico
      print('Error al obtener servicios: $e');
      throw Exception('No se pudieron cargar los servicios');
    }
  }

  @override
  Future<Service> getServiceById(String id) async {
    try {
      final data = await _supabaseClient
          .from('services')
          .select()
          .eq('id', id)
          .single();

      return Service(
        id: data['id'].toString(),
        name: data['name'],
        description: data['description'],
        durationMinutes: data['duration_minutes'],
        price: (data['price_cents'] as int) / 100.0,
      );
    } catch (e) {
      print('Error al obtener servicio por ID: $e');
      throw Exception('No se pudo cargar el servicio');
    }
  }
}