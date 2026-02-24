import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../domain/repositories/user_repository.dart';
import 'governorate_event.dart';
import 'governorate_state.dart';

class GovernorateBloc extends Bloc<GovernorateEvent, GovernorateState> {
  final UserRepository _userRepository;
  int? _categoryId;

  GovernorateBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const GovernorateInitial()) {
    on<FetchGovernoratesEvent>(_onFetchGovernorates);
    on<SelectGovernorateEvent>(_onSelectGovernorate);
    on<FetchMoreCasesEvent>(_onFetchMoreCases);
    on<RefreshGovernorateDataEvent>(_onRefreshData);
  }

  Future<void> _onFetchGovernorates(
    FetchGovernoratesEvent event,
    Emitter<GovernorateState> emit,
  ) async {
    emit(const GovernorateLoading());
    _categoryId = event.categoryId;

    final result = await _userRepository.getGovernorates();

    result.fold(
      (failure) => emit(GovernorateError(_mapFailureToMessage(failure))),
      (governorates) {
        emit(GovernorateLoaded(
          governorates: governorates,
          selectedCategoryId: _categoryId,
        ));
      },
    );
  }

  Future<void> _onSelectGovernorate(
    SelectGovernorateEvent event,
    Emitter<GovernorateState> emit,
  ) async {
    if (state is GovernorateLoaded) {
      final currentState = state as GovernorateLoaded;
      
      emit(currentState.copyWith(
        selectedGovernorateId: event.governorateId,
        cases: [],
        currentPage: 1,
        hasMoreCases: true,
      ));

      final result = await _userRepository.getCasesByGovernorate(
        event.governorateId,
        categoryId: _categoryId,
        page: 1,
      );

      result.fold(
        (failure) => emit(GovernorateError(_mapFailureToMessage(failure))),
        (cases) {
          emit(currentState.copyWith(
            selectedGovernorateId: event.governorateId,
            cases: cases,
            hasMoreCases: cases.length >= AppConstants.defaultPageSize,
            currentPage: 1,
          ));
        },
      );
    }
  }

  Future<void> _onFetchMoreCases(
    FetchMoreCasesEvent event,
    Emitter<GovernorateState> emit,
  ) async {
    if (state is GovernorateLoaded) {
      final currentState = state as GovernorateLoaded;
      
      if (!currentState.hasMoreCases || currentState.selectedGovernorateId == null) {
        return;
      }

      emit(CasesLoadingMore(
        governorates: currentState.governorates,
        currentCases: currentState.cases,
        selectedGovernorateId: currentState.selectedGovernorateId,
        selectedCategoryId: currentState.selectedCategoryId,
      ));

      final nextPage = currentState.currentPage + 1;
      final result = await _userRepository.getCasesByGovernorate(
        currentState.selectedGovernorateId!,
        categoryId: _categoryId,
        page: nextPage,
      );

      result.fold(
        (failure) => emit(GovernorateError(_mapFailureToMessage(failure))),
        (newCases) {
          final allCases = [...currentState.cases, ...newCases];
          emit(currentState.copyWith(
            cases: allCases,
            hasMoreCases: newCases.length >= AppConstants.defaultPageSize,
            currentPage: nextPage,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshData(
    RefreshGovernorateDataEvent event,
    Emitter<GovernorateState> emit,
  ) async {
    final result = await _userRepository.getGovernorates();

    result.fold(
      (failure) => emit(GovernorateError(_mapFailureToMessage(failure))),
      (governorates) {
        emit(GovernorateLoaded(
          governorates: governorates,
          selectedCategoryId: _categoryId,
        ));
      },
    );
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType.toString()) {
      case 'ServerFailure':
        return ErrorMessages.serverError;
      case 'NetworkFailure':
        return ErrorMessages.networkError;
      default:
        return ErrorMessages.unknownError;
    }
  }
}
