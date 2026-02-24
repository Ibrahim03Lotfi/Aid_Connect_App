import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String role;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

class SubmitOrganizationRequestEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String description;
  final String registrationNumber;

  const SubmitOrganizationRequestEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.registrationNumber,
  });

  @override
  List<Object?> get props => [name, email, phone, address, description, registrationNumber];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class TogglePasswordVisibilityEvent extends AuthEvent {
  const TogglePasswordVisibilityEvent();
}
