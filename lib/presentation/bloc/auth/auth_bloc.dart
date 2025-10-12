import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/profile.dart';
import '../../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUserUseCase;

  AuthBloc({required this.registerUserUseCase}) : super(AuthInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final profile = Profile(
        id: '', // Se pone en la capa de datos
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
      );

      await registerUserUseCase.call(profile, event.password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
