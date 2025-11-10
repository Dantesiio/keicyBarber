import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/profile_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  final ProfileDataSource profileDataSource;

  AuthRepositoryImpl({
    required this.authDataSource,
    required this.profileDataSource,
  });

  @override
  Future<void> registerUser(Profile profile, String password) async {
    final userId = await authDataSource.signUp(profile.email, password);
    profile.id = userId;
    await profileDataSource.createProfile(profile);
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    return await authDataSource.signInWithEmailAndPassword(email, password);
  }
}
