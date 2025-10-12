import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthDataSource {
  Future<String> signUp(String email, String password);
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient client;

  AuthDataSourceImpl(this.client);

  @override
  Future<String> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return response.user!.id;
      } else {
        throw const AuthException(
          'Error en el registro: No se pudo crear el usuario.',
        );
      }
    } on AuthException catch (e) {
      throw AuthException(e.message);
    }
  }
}
