import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/organization_repository.dart';
import 'org_profile_event.dart';
import 'org_profile_state.dart';

class OrgProfileBloc extends Bloc<OrgProfileEvent, OrgProfileState> {
  final OrganizationRepository _repository;

  OrgProfileBloc({required OrganizationRepository repository})
    : _repository = repository,
      super(const OrgProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<OrgProfileState> emit,
  ) async {
    emit(const OrgProfileLoading());
    final result = await _repository.getProfile();
    result.fold(
      (failure) => emit(OrgProfileError(failure.message)),
      (profile) => emit(OrgProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<OrgProfileState> emit,
  ) async {
    emit(const OrgProfileLoading());
    final result = await _repository.updateProfile(
      name: event.name,
      phone: event.phone,
      address: event.address,
      description: event.description,
      registrationNumber: event.registrationNumber,
    );
    result.fold(
      (failure) => emit(OrgProfileError(failure.message)),
      (_) => emit(const OrgProfileUpdated()),
    );
  }
}
