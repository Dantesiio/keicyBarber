import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Service>> getServices() async {
    // Servicios activos
    final rows = await _client
        .from('services')
        .select('id, name, description, price_cents, duration_minutes, status')
        .eq('status', 'activo')
        .order('id');

    return (rows as List)
        .map((r) => Service(
              id: r['id'].toString(),
              name: r['name'] as String,
              description: (r['description'] as String?) ?? '',
              durationMinutes: r['duration_minutes'] as int,
              price: (r['price_cents'] as int).toDouble(),
            ))
        .toList();
  }
}
