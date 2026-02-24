import 'package:equatable/equatable.dart';
import '../../../domain/entities/case.dart';
import '../../../domain/entities/governorate.dart';

abstract class GovernorateState extends Equatable {
  const GovernorateState();

  @override
  List<Object?> get props => [];
}

class GovernorateInitial extends GovernorateState {
  const GovernorateInitial();
}

class GovernorateLoading extends GovernorateState {
  const GovernorateLoading();
}

class GovernorateLoaded extends GovernorateState {
  final List<Governorate> governorates;
  final List<Case> cases;
  final int? selectedGovernorateId;
  final int? selectedCategoryId;
  final bool hasMoreCases;
  final int currentPage;

  const GovernorateLoaded({
    required this.governorates,
    this.cases = const [],
    this.selectedGovernorateId,
    this.selectedCategoryId,
    this.hasMoreCases = true,
    this.currentPage = 1,
  });

  GovernorateLoaded copyWith({
    List<Governorate>? governorates,
    List<Case>? cases,
    int? selectedGovernorateId,
    int? selectedCategoryId,
    bool? hasMoreCases,
    int? currentPage,
  }) {
    return GovernorateLoaded(
      governorates: governorates ?? this.governorates,
      cases: cases ?? this.cases,
      selectedGovernorateId: selectedGovernorateId ?? this.selectedGovernorateId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      hasMoreCases: hasMoreCases ?? this.hasMoreCases,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        governorates,
        cases,
        selectedGovernorateId,
        selectedCategoryId,
        hasMoreCases,
        currentPage,
      ];
}

class GovernorateError extends GovernorateState {
  final String message;

  const GovernorateError(this.message);

  @override
  List<Object?> get props => [message];
}

class CasesLoadingMore extends GovernorateState {
  final List<Governorate> governorates;
  final List<Case> currentCases;
  final int? selectedGovernorateId;
  final int? selectedCategoryId;

  const CasesLoadingMore({
    required this.governorates,
    required this.currentCases,
    this.selectedGovernorateId,
    this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [
        governorates,
        currentCases,
        selectedGovernorateId,
        selectedCategoryId,
      ];
}
