import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationRepositoryImpl implements LocationRepository {
  final _sb = Supabase.instance.client;

  @override
  Future<List<Location>> getLocations() async {
    final rows = await _sb
        .from('locations')
        .select('id, name, address')
        .order('id');

    return (rows as List).map((r) {
      return Location(
        id: r['id'].toString(),
        name: r['name'] as String,
        address: (r['address'] as String?) ?? ''
      );
    }).toList();
  }
}