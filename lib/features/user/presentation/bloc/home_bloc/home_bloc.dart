import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../domain/entities/case.dart';
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
    debugPrint('HomeBloc: Fetching home data...');

    // Fetch categories
    final categoriesResult = await _userRepository.getCategories();
    if (categoriesResult.isLeft()) {
      final failure = categoriesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    final categories = categoriesResult.getOrElse(() => []);

    // Fetch cases
    final casesResult = await _userRepository.getAllCases(page: 1);
    if (casesResult.isLeft()) {
      final failure = casesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    final cases = casesResult.getOrElse(() => []);

    // Collect urgent cases for the spotlight carousel
    final urgentCases = cases.where((c) => c.priority.toLowerCase() == 'urgent').toList();
    final heroCases = urgentCases.isNotEmpty ? urgentCases : (cases.isNotEmpty ? [cases.first] : <Case>[]);

    emit(HomeLoaded(
      categories: categories,
      cases: cases,
      urgentCases: heroCases,
      hasMoreCases: cases.length >= AppConstants.defaultPageSize,
      currentPage: 1,
      selectedCategoryId: null,
    ));
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
        urgentCases: currentState.urgentCases,
        selectedCategoryId: currentState.selectedCategoryId,
      ));
      
      final nextPage = currentState.currentPage + 1;
      final result = currentState.selectedCategoryId == null
          ? await _userRepository.getAllCases(page: nextPage)
          : await _userRepository.getCasesByCategory(
              currentState.selectedCategoryId!,
              page: nextPage,
            );
      
      if (result.isLeft()) {
        final failure = result.swap().getOrElse(() => ServerFailure('Unknown error'));
        emit(HomeError(_mapFailureToMessage(failure)));
        return;
      }
      
      final allCases = result.getOrElse(() => []);
      emit(HomeLoaded(
        categories: currentState.categories,
        cases: [...currentState.cases, ...allCases],
        urgentCases: currentState.urgentCases,
        hasMoreCases: allCases.length >= AppConstants.defaultPageSize,
        currentPage: nextPage,
        selectedCategoryId: currentState.selectedCategoryId,
      ));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    final categoriesResult = await _userRepository.getCategories();
    if (categoriesResult.isLeft()) {
      final failure = categoriesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    final categories = categoriesResult.getOrElse(() => []);

    final casesResult = await _userRepository.getAllCases(page: 1);
    if (casesResult.isLeft()) {
      final failure = casesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    final cases = casesResult.getOrElse(() => []);

    final urgentCases = cases.where((c) => c.priority.toLowerCase() == 'urgent').toList();
    final heroCases = urgentCases.isNotEmpty ? urgentCases : (cases.isNotEmpty ? [cases.first] : <Case>[]);

    emit(HomeLoaded(
      categories: categories,
      cases: cases,
      urgentCases: heroCases,
      hasMoreCases: cases.length >= AppConstants.defaultPageSize,
      currentPage: 1,
      selectedCategoryId: null,
    ));
  }

  Future<void> _onCategorySelected(
    CategorySelectedEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    
    final currentState = state as HomeLoaded;
    final targetCategoryId = event.categoryId == 0 ? null : event.categoryId;

    // Do NOT emit HomeLoading()! Keep the UI intact and indicate loading just for the cases
    emit(currentState.copyWith(
      selectedCategoryId: targetCategoryId,
      isCategoryLoading: true,
    ));

    final casesResult = event.categoryId == 0
        ? await _userRepository.getAllCases(page: 1)
        : await _userRepository.getCasesByCategory(
            event.categoryId,
            page: 1,
          );

    if (casesResult.isLeft()) {
      final failure = casesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      debugPrint('HomeBloc: Category selection error - $failure');
      emit(currentState.copyWith(isCategoryLoading: false));
      return;
    }
    
    final cases = casesResult.getOrElse(() => []);
    emit(currentState.copyWith(
      cases: cases,
      hasMoreCases: cases.length >= AppConstants.defaultPageSize,
      currentPage: 1,
      selectedCategoryId: targetCategoryId,
      isCategoryLoading: false,
    ));
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
