import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileDataSource {
  Future<void> createProfile(Profile profile);
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final SupabaseClient client;

  ProfileDataSourceImpl(this.client);

  @override
  Future<void> createProfile(Profile profile) async {
    final response = await client.from('profiles').insert(profile.toJson());
    // TODO: MANEJO DE ERRORES SI RESPONSE ES NULO
  }
}
