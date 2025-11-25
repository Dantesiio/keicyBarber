import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_profile.dart';
import '../../../domain/usecases/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfileUseCase;
  final UpdateProfile updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await getProfileUseCase.call();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(event.profile));
      try {
        await updateProfileUseCase.call(event.profile);
        emit(ProfileUpdateSuccess(event.profile));
        // Recargar el perfil actualizado
        final updatedProfile = await getProfileUseCase.call();
        emit(ProfileLoaded(updatedProfile));
      } catch (e) {
        emit(ProfileUpdateError(e.toString()));
        // Restaurar el estado anterior
        emit(currentState);
      }
    }
  }
}
