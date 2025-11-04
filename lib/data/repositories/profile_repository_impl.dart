import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource profileDataSource;
  final SupabaseClient client;

  ProfileRepositoryImpl({
    required this.profileDataSource,
    required this.client,
  });

  @override
  Future<Profile> getCurrentUserProfile() async {
    final profileData = await profileDataSource.getCurrentUserProfileData();

    // El email no está en la tabla 'profiles', lo sacamos de la sesión de auth
    final email = client.auth.currentUser!.email!;

    profileData['email'] = email;

    return Profile.fromJson(profileData);
  }
}
