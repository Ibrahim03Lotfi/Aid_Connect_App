import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;

  bool _isPasswordVisible = false;

  AuthBloc({
    required AuthRepository authRepository,
    required LocalStorageService localStorage,
  })  : _authRepository = authRepository,
        _localStorage = localStorage,
        super(const AuthFormState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SubmitOrganizationRequestEvent>(_onSubmitOrganizationRequest);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<TogglePasswordVisibilityEvent>(_onTogglePasswordVisibility);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthFormState(isLoading: true));

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
      role: event.role,
    );

    result.fold(
      (failure) => emit(AuthFormState(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
        fieldErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (user) async {
        await _localStorage.saveRole(user.role);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthFormState(isLoading: true));

    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFormState(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
        fieldErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (user) async {
        await _localStorage.saveRole(user.role);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSubmitOrganizationRequest(
    SubmitOrganizationRequestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthFormState(isLoading: true));

    final result = await _authRepository.submitOrganizationRequest(
      name: event.name,
      email: event.email,
      phone: event.phone,
      address: event.address,
      description: event.description,
      registrationNumber: event.registrationNumber,
    );

    result.fold(
      (failure) => emit(AuthFormState(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
        fieldErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (_) => emit(const OrganizationRequestSubmitted()),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    await _authRepository.logout();
    await _localStorage.clearAll();

    emit(const Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.checkAuthStatus();

    result.fold(
      (_) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibilityEvent event,
    Emitter<AuthState> emit,
  ) {
    _isPasswordVisible = !_isPasswordVisible;
    emit(PasswordVisibilityChanged(_isPasswordVisible));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return ErrorMessages.serverError;
      case NetworkFailure:
        return ErrorMessages.networkError;
      case ValidationFailure:
        return failure.message;
      case UnauthorizedFailure:
        return ErrorMessages.unauthorizedError;
      case NotFoundFailure:
        return ErrorMessages.notFoundError;
      case TimeoutFailure:
        return ErrorMessages.timeoutError;
      default:
        return ErrorMessages.unknownError;
    }
  }
}
