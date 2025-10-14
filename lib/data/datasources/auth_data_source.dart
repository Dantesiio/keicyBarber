import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthDataSource {
  Future<String> signUp(String email, String password);
  Future<void> signInWithEmailAndPassword(String email, String password);
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient client;

  AuthDataSourceImpl(this.client);

  @override
  Future<String> signUp(String email, String password) async {
    try {
      print(
        '[AuthDataSource] Enviando petición signUp a Supabase para: $email',
      );
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        print(
          '[AuthDataSource] Supabase devolvió el User ID: ${response.user!.id}',
        );
        return response.user!.id;
      } else {
        throw const AuthException(
          'Error en el registro: No se pudo crear el usuario.',
        );
      }
    } on AuthException catch (e) {
      print('[AuthDataSource] AuthException de Supabase: ${e.message}');
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      print(
        '[AuthDataSource] Enviando petición signIn a Supabase para: $email',
      );
      await client.auth.signInWithPassword(email: email, password: password);
      print('[AuthDataSource] SignIn exitoso para: $email');
    } on AuthException catch (e) {
      print('[AuthDataSource] AuthException en SignIn: ${e.message}');
      throw AuthException(e.message);
    }
  }
}
