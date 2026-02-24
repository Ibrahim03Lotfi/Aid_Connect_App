import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final Map<String, dynamic>? errors;

  const AuthError(this.message, {this.errors});

  @override
  List<Object?> get props => [message, errors];
}

class PasswordVisibilityChanged extends AuthState {
  final bool isVisible;

  const PasswordVisibilityChanged(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}

class OrganizationRequestSubmitted extends AuthState {
  const OrganizationRequestSubmitted();
}

class AuthFormState extends AuthState {
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const AuthFormState({
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors,
  });

  AuthFormState copyWith({
    bool? isPasswordVisible,
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return AuthFormState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors,
    );
  }

  @override
  List<Object?> get props => [isPasswordVisible, isLoading, errorMessage, fieldErrors];
}
