import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/profile.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUserUseCase;
  final LoginUser loginUserUseCase;

  AuthBloc({required this.registerUserUseCase, required this.loginUserUseCase})
    : super(AuthInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('[AuthBloc] Intentando registrar a: ${event.email}');

      final profile = Profile(
        id: '', // Se pone en la capa de datos
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
      );

      await registerUserUseCase.call(profile, event.password);
      print('[AuthBloc] Registro exitoso para: ${event.email}');
      emit(AuthSuccess());
    } catch (e) {
      print('[AuthBloc] Error en el registro: ${e.toString()}');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('--- PASO 2: BLOC --- Recibido evento, llamando al caso de uso.');
      print('[AuthBloc] Intentando login para: ${event.email}');
      await loginUserUseCase.call(event.email, event.password);
      print('[AuthBloc] Login exitoso para: ${event.email}');
      emit(AuthSuccess());
    } catch (e) {
      print('--- PASO 4: BLOC --- ¡ERROR CAPTURADO! ${e.toString()}');
      print('[AuthBloc] Error en login: ${e.toString()}');
      emit(AuthFailure(e.toString()));
    }
  }
}
