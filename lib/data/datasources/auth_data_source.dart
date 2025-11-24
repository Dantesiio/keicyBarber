import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthDataSource {
  Future<String> signUp(String email, String password);
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signOut();
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
      print('--- PASO 3: DATA SOURCE --- Enviando petición a Supabase.');
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // --- AÑADIR ESTOS PRINTS DE DIAGNÓSTICO ---
      print('================ SUPABASE RESPONSE ================');
      print('Response Session: ${response.session}');
      print('Response User: ${response.user}');
      print('===================================================');

      if (response.session == null) {
        print('[AuthDataSource] Error en SignIn: Credenciales inválidas.');
        throw const AuthException('Invalid login credentials');
      }

      print('[AuthDataSource] SignIn exitoso para: $email');
    } on AuthException catch (e) {
      print('[AuthDataSource] AuthException en SignIn: ${e.message}');
      throw AuthException(e.message);
    } catch (e) {
      print('[AuthDataSource] Error inesperado en SignIn: ${e.toString()}');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      print('[AuthDataSource] Enviando petición de recuperación de contraseña para: $email');
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'keicybarber://reset-password', // URL de deep link
      );
      print('[AuthDataSource] Email de recuperación enviado exitosamente a: $email');
    } catch (e) {
      print('[AuthDataSource] Error al enviar email de recuperación: ${e.toString()}');
      throw Exception('Error al enviar el email de recuperación: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('[AuthDataSource] Cerrando sesión del usuario');
      await client.auth.signOut();
      print('[AuthDataSource] Sesión cerrada exitosamente');
    } catch (e) {
      print('[AuthDataSource] Error al cerrar sesión: ${e.toString()}');
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }
}
