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
  final bool hasMoreCases;
  final int currentPage;
  final int? selectedCategoryId;

  const HomeLoaded({
    required this.categories,
    required this.cases,
    this.hasMoreCases = true,
    this.currentPage = 1,
    this.selectedCategoryId,
  });

  HomeLoaded copyWith({
    List<Category>? categories,
    List<Case>? cases,
    bool? hasMoreCases,
    int? currentPage,
    int? selectedCategoryId,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      cases: cases ?? this.cases,
      hasMoreCases: hasMoreCases ?? this.hasMoreCases,
      currentPage: currentPage ?? this.currentPage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [categories, cases, hasMoreCases, currentPage, selectedCategoryId];
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
  final int? selectedCategoryId;

  const CasesLoadingMore({
    required this.categories,
    required this.currentCases,
    this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [categories, currentCases, selectedCategoryId];
}
