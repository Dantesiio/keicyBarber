import '../entities/profile.dart';

abstract class AuthRepository {
  Future<void> registerUser(Profile profile, String password);
  Future<void> signInWithEmailAndPassword(String email, String password);
}
