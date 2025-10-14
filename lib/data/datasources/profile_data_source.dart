import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileDataSource {
  Future<void> createProfile(Profile profile);

  Future<Map<String, dynamic>> getCurrentUserProfileData();
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final SupabaseClient client;

  ProfileDataSourceImpl(this.client);

  @override
  Future<void> createProfile(Profile profile) async {
    final response = await client.from('profiles').insert(profile.toJson());
    // TODO: MANEJO DE ERRORES SI RESPONSE ES NULO
  }

  @override
  Future<Map<String, dynamic>> getCurrentUserProfileData() async {
    try {
      final userId = client.auth.currentUser!.id;
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single(); // .single() es clave para obtener un solo objeto
      return data;
    } catch (e) {
      print('Error en ProfileDataSource: ${e.toString()}');
      rethrow; // Relanza el error para que sea manejado en capas superiores
    }
  }
}
