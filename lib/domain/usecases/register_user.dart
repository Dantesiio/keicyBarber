import '../entities/profile.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<void> call(Profile profile, String password) async {
    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres.');
    }
    return await repository.registerUser(profile, password);
  }
}
