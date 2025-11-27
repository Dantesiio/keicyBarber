import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceDataSource {
  final SupabaseClient _sb;

  ServiceDataSource(this._sb);

  Future<List<Map<String, dynamic>>> fetchActiveServices() async {
    try {
      return await _sb
          .from('services')
          .select('id, name, description, price_cents, duration_minutes, status')
          .eq('status', 'activo')
          .order('id');
    } catch (e) {
      rethrow;
    }
  }
}