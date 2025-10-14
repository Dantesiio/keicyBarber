import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final DateTime? birthDate;

  const RegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.birthDate,
  });
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
