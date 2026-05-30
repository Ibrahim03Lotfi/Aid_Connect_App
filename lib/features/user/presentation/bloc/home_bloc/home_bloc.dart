import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
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
    debugPrint('HomeBloc: Fetching home data...');

    // Fetch categories
    final categoriesResult = await _userRepository.getCategories();
    if (categoriesResult.isLeft()) {
      final failure = categoriesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      debugPrint('HomeBloc: Categories error - $failure');
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    final categories = categoriesResult.getOrElse(() => []);
    debugPrint('HomeBloc: Got ${categories.length} categories');

    // Fetch cases
    final casesResult = await _userRepository.getAllCases(page: 1);
    if (casesResult.isLeft()) {
      final failure = casesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      debugPrint('HomeBloc: Cases error - $failure');
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    final cases = casesResult.getOrElse(() => []);
    debugPrint('HomeBloc: Got ${cases.length} cases');

    emit(HomeLoaded(
      categories: categories,
      cases: cases,
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

    emit(HomeLoaded(
      categories: categories,
      cases: cases,
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
    emit(const HomeLoading());
    debugPrint('HomeBloc: Category selected - ${event.categoryId}');
    
    debugPrint('HomeBloc: About to call ${event.categoryId == 0 ? "getAllCases" : "getCasesByCategory"} with categoryId: ${event.categoryId}');
    
    final casesResult = event.categoryId == 0
        ? await _userRepository.getAllCases(page: 1)
        : await _userRepository.getCasesByCategory(
            event.categoryId,
            page: 1,
          );

    debugPrint('HomeBloc: Repository call completed. isLeft: ${casesResult.isLeft()}');
    
    if (casesResult.isLeft()) {
      final failure = casesResult.swap().getOrElse(() => ServerFailure('Unknown error'));
      debugPrint('HomeBloc: Category selection error - $failure');
      emit(HomeError(_mapFailureToMessage(failure)));
      return;
    }
    
    final cases = casesResult.getOrElse(() => []);
    debugPrint('HomeBloc: Got ${cases.length} cases for category ${event.categoryId}');
    emit(HomeLoaded(
      categories: currentState.categories,
      cases: cases,
      hasMoreCases: cases.length >= AppConstants.defaultPageSize,
      currentPage: 1,
      selectedCategoryId: event.categoryId == 0 ? null : event.categoryId,
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
