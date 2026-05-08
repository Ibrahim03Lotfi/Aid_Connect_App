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
    on<CategorySelectedEvent>(_onCategorySelected);
  }

  Future<void> _onFetchHomeData(
    FetchHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final categoriesResult = await _userRepository.getCategories();
    final casesResult = await _userRepository.getAllCases(page: 1);

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
              selectedCategoryId: null,
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
        selectedCategoryId: currentState.selectedCategoryId,
      ));
      
      final nextPage = currentState.currentPage + 1;
      final result = currentState.selectedCategoryId == null
          ? await _userRepository.getAllCases(page: nextPage)
          : await _userRepository.getCasesByCategory(
              categoryId: currentState.selectedCategoryId!,
              page: nextPage,
            );
      
      result.fold(
        (failure) => emit(HomeError(_mapFailureToMessage(failure))),
        (allCases) {
          emit(HomeLoaded(
            categories: currentState.categories,
            cases: allCases,
            hasMoreCases: allCases.length >= AppConstants.defaultPageSize,
            currentPage: nextPage,
            selectedCategoryId: currentState.selectedCategoryId,
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
    final casesResult = await _userRepository.getAllCases(page: 1);

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
              selectedCategoryId: null,
            ));
          },
        );
      },
    );
  }

  Future<void> _onCategorySelected(
    CategorySelectedEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    emit(const HomeLoading());
    
    final casesResult = event.categoryId == 0
        ? await _userRepository.getAllCases(page: 1)
        : await _userRepository.getCasesByCategory(
            categoryId: event.categoryId,
            page: 1,
          );

    casesResult.fold(
      (failure) => emit(HomeError(_mapFailureToMessage(failure))),
      (cases) {
        emit(HomeLoaded(
          categories: currentState.categories,
          cases: cases,
          hasMoreCases: cases.length >= AppConstants.defaultPageSize,
          currentPage: 1,
          selectedCategoryId: event.categoryId == 0 ? null : event.categoryId,
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
      case 'UnauthorizedFailure':
        return ErrorMessages.unauthorizedError;
      default:
        return ErrorMessages.unknownError;
    }
  }
}
