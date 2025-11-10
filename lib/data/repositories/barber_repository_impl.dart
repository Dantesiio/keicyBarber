import '../../domain/entities/barber.dart';
import '../../domain/repositories/barber_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarberRepositoryImpl implements BarberRepository {
  final SupabaseClient _sb = Supabase.instance.client;

  @override
  Future<List<Barber>> getBarbersByLocation(String locationId) async {
    // Barberos asociados a la sede
    final rel = await _sb
        .from('barber_locations')
        .select('barber_id')
        .eq('location_id', int.parse(locationId));

    final ids = (rel as List).map((e) => e['barber_id'] as String).toList();
    if (ids.isEmpty) return [];

    // Nombre desde profiles
    final barbers = await _sb
        .from('barbers')
        .select(
          'profile_id, average_rating, profiles!inner(first_name, last_name)',
        )
        .inFilter('profile_id', ids);

    // Especialidades por barbero
    final bs = await _sb
        .from('barber_services')
        .select('barber_id, services!inner(name)')
        .inFilter('barber_id', ids);

    // Mapear especialidades
    final Map<String, List<String>> specByBarber = {};
    for (final row in (bs as List)) {
      final bId = row['barber_id'] as String;
      final svcName = (row['services'] as Map)['name'] as String;
      specByBarber.putIfAbsent(bId, () => []).add(svcName);
    }

    // Ensamblar entidad
    return (barbers as List).map((r) {
      final prof = r['profiles'] as Map;
      final id = r['profile_id'] as String;

      return Barber(
        id: id,
        name: '${prof['first_name']} ${prof['last_name']}'.trim(),
        rating: (r['average_rating'] as num?)?.toDouble() ?? 0.0,
        specialtys: specByBarber[id] ?? const [],
        locationId: locationId,
      );
    }).toList();
  }
}
