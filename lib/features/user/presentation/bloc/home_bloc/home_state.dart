import 'package:equatable/equatable.dart';
import '../../domain/entities/case.dart';
import '../../domain/entities/category.dart';

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

  const HomeLoaded({
    required this.categories,
    required this.cases,
    this.hasMoreCases = true,
    this.currentPage = 1,
  });

  HomeLoaded copyWith({
    List<Category>? categories,
    List<Case>? cases,
    bool? hasMoreCases,
    int? currentPage,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      cases: cases ?? this.cases,
      hasMoreCases: hasMoreCases ?? this.hasMoreCases,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [categories, cases, hasMoreCases, currentPage];
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

  const CasesLoadingMore({
    required this.categories,
    required this.currentCases,
  });

  @override
  List<Object?> get props => [categories, currentCases];
}
