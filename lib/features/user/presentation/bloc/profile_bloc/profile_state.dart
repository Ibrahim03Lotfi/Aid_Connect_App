import 'package:equatable/equatable.dart';
import '../../../../../features/auth/domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}

class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}

class LogoutSuccess extends ProfileState {
  const LogoutSuccess();
}
