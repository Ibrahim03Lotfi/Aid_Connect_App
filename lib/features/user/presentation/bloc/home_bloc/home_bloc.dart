import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../domain/repositories/user_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepository;

  HomeBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const HomeInitial()) {
    on<FetchHomeDataEvent>(_onFetchHomeData);
    on<FetchMoreCasesEvent>(_onFetchMoreCases);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onFetchHomeData(
    FetchHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final categoriesResult = await _userRepository.getCategories();
    final casesResult = await _userRepository.getLatestCases(page: 1);

    categoriesResult.fold(
      (failure) => emit(HomeError(_mapFailureToMessage(failure))),
      (categories) {
        casesResult.fold(
          (failure) => emit(HomeError(_mapFailureToMessage(failure))),
          (cases) {
            emit(HomeLoaded(
              categories: categories,
              cases: cases,
              hasMoreCases: cases.length >= AppConstants.defaultPageSize,
              currentPage: 1,
            ));
          },
        );
      },
    );
  }

  Future<void> _onFetchMoreCases(
    FetchMoreCasesEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      if (!currentState.hasMoreCases) return;

      emit(CasesLoadingMore(
        categories: currentState.categories,
        currentCases: currentState.cases,
      ));

      final nextPage = currentState.currentPage + 1;
      final result = await _userRepository.getLatestCases(page: nextPage);

      result.fold(
        (failure) => emit(HomeError(_mapFailureToMessage(failure))),
        (newCases) {
          final allCases = [...currentState.cases, ...newCases];
          emit(HomeLoaded(
            categories: currentState.categories,
            cases: allCases,
            hasMoreCases: newCases.length >= AppConstants.defaultPageSize,
            currentPage: nextPage,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    final categoriesResult = await _userRepository.getCategories();
    final casesResult = await _userRepository.getLatestCases(page: 1);

    categoriesResult.fold(
      (failure) => emit(HomeError(_mapFailureToMessage(failure))),
      (categories) {
        casesResult.fold(
          (failure) => emit(HomeError(_mapFailureToMessage(failure))),
          (cases) {
            emit(HomeLoaded(
              categories: categories,
              cases: cases,
              hasMoreCases: cases.length >= AppConstants.defaultPageSize,
              currentPage: 1,
            ));
          },
        );
      },
    );
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType.toString()) {
      case 'ServerFailure':
        return ErrorMessages.serverError;
      case 'NetworkFailure':
        return ErrorMessages.networkError;
      case 'UnauthorizedFailure':
        return ErrorMessages.unauthorizedError;
      default:
        return ErrorMessages.unknownError;
    }
  }
}
