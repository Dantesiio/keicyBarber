import 'package:supabase_flutter/supabase_flutter.dart';

class LocationDataSource {
  final SupabaseClient _sb;

  LocationDataSource(this._sb);

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      return await _sb
          .from('locations')
          .select('id, name, address, latitude, longitude')
          .order('id');
    } catch (e) {
      rethrow;
    }
  }
}