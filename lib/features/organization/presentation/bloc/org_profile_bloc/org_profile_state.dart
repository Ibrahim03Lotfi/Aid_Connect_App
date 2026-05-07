import 'package:equatable/equatable.dart';
import '../../../domain/entities/org_profile.dart';

abstract class OrgProfileState extends Equatable {
  const OrgProfileState();

  @override
  List<Object?> get props => [];
}

class OrgProfileInitial extends OrgProfileState {
  const OrgProfileInitial();
}

class OrgProfileLoading extends OrgProfileState {
  const OrgProfileLoading();
}

class OrgProfileLoaded extends OrgProfileState {
  final OrgProfile profile;

  const OrgProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OrgProfileUpdated extends OrgProfileState {
  const OrgProfileUpdated();
}

class OrgProfileError extends OrgProfileState {
  final String message;

  const OrgProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
