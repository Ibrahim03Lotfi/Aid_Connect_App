import 'package:equatable/equatable.dart';
import '../../../domain/entities/case.dart';
import '../../../domain/entities/category.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final List<Case> cases;
  final List<Case> urgentCases;
  final bool hasMoreCases;
  final int currentPage;
  final int? selectedCategoryId;
  final bool isCategoryLoading;

  const HomeLoaded({
    required this.categories,
    required this.cases,
    this.urgentCases = const [],
    this.hasMoreCases = true,
    this.currentPage = 1,
    this.selectedCategoryId,
    this.isCategoryLoading = false,
  });

  HomeLoaded copyWith({
    List<Category>? categories,
    List<Case>? cases,
    List<Case>? urgentCases,
    bool? hasMoreCases,
    int? currentPage,
    int? selectedCategoryId,
    bool? isCategoryLoading,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      cases: cases ?? this.cases,
      urgentCases: urgentCases ?? this.urgentCases,
      hasMoreCases: hasMoreCases ?? this.hasMoreCases,
      currentPage: currentPage ?? this.currentPage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isCategoryLoading: isCategoryLoading ?? this.isCategoryLoading,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        cases,
        urgentCases,
        hasMoreCases,
        currentPage,
        selectedCategoryId,
        isCategoryLoading,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class CasesLoadingMore extends HomeState {
  final List<Category> categories;
  final List<Case> currentCases;
  final List<Case> urgentCases;
  final int? selectedCategoryId;

  const CasesLoadingMore({
    required this.categories,
    required this.currentCases,
    this.urgentCases = const [],
    this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [categories, currentCases, urgentCases, selectedCategoryId];
}
