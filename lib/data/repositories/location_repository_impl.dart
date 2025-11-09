import 'package:keicybarber/domain/entities/location.dart';
import 'package:keicybarber/domain/repositories/location_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationRepositoryImpl implements LocationRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<Location>> getLocations() async {
    try {
      final response = await _supabaseClient
          .from('locations')
          .select('*')
          .eq('status', 'abierta');
      // Creamos una nueva lista con el tipo correcto para satisfacer al compilador web.
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Mapeamos la respuesta (una lista de mapas) a una lista de objetos Location
      final locations = data.map((item) {
        return Location(
          id: item['id'].toString(),
          name: item['name'],
          address: item['address'],
          number: item['contact_number'],
        );
      }).toList();

      return locations;
    } catch (e) {
      // Manejo de errores básico
      print('Error al obtener locations: $e');
      throw Exception('No se pudieron cargar los locations');
    }
  }
}