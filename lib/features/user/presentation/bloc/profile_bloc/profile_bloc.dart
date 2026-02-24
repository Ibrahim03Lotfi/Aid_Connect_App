import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/local_storage_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;

  ProfileBloc({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required LocalStorageService localStorage,
  })  : _userRepository = userRepository,
        _authRepository = authRepository,
        _localStorage = localStorage,
        super(const ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _authRepository.checkAuthStatus();

    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (user) {
        if (user != null) {
          emit(ProfileLoaded(user: user));
        } else {
          emit(const ProfileError('غير مسجل الدخول'));
        }
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _userRepository.updateProfile(
      name: event.name,
      phone: event.phone,
    );

    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (_) => emit(const ProfileUpdateSuccess()),
    );

    // Refresh profile data
    add(const FetchProfileEvent());
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _userRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (_) => emit(const PasswordChangeSuccess()),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    await _authRepository.logout();
    await _localStorage.clearAll();

    emit(const LogoutSuccess());
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType.toString()) {
      case 'ServerFailure':
        return 'حدث خطأ في الخادم';
      case 'NetworkFailure':
        return 'لا يوجد اتصال بالإنترنت';
      case 'ValidationFailure':
        return failure.message;
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
