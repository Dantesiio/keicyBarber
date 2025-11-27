import 'package:supabase_flutter/supabase_flutter.dart';

class BarberDataSource {
  final SupabaseClient _sb;

  BarberDataSource(this._sb);

  Future<List<Map<String, dynamic>>> fetchBarberRelations(String locationId) async {
    try {
      return await _sb
          .from('barber_locations')
          .select('barber_id')
          .eq('location_id', int.parse(locationId));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchBarberProfiles(List<String> ids) async {
    try {
      return await _sb
          .from('barbers')
          .select('profile_id, average_rating, profiles!inner(first_name, last_name)')
          .inFilter('profile_id', ids);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchBarberServices(List<String> ids) async {
    try {
      return await _sb
          .from('barber_services')
          .select('barber_id, services!inner(name)')
          .inFilter('barber_id', ids);
    } catch (e) {
      rethrow;
    }
  }
}