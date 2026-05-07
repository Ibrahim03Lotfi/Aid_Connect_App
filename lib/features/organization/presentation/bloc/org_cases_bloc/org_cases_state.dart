import 'package:equatable/equatable.dart';
import '../../../domain/entities/org_case.dart';

abstract class OrgCasesState extends Equatable {
  const OrgCasesState();

  @override
  List<Object?> get props => [];
}

class OrgCasesInitial extends OrgCasesState {
  const OrgCasesInitial();
}

class OrgCasesLoading extends OrgCasesState {
  const OrgCasesLoading();
}

class OrgCasesLoaded extends OrgCasesState {
  final List<OrgCase> cases;
  final int currentPage;
  final bool hasMore;

  const OrgCasesLoaded({
    required this.cases,
    required this.currentPage,
    this.hasMore = true,
  });

  OrgCasesLoaded copyWith({
    List<OrgCase>? cases,
    int? currentPage,
    bool? hasMore,
  }) {
    return OrgCasesLoaded(
      cases: cases ?? this.cases,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [cases, currentPage, hasMore];
}

class OrgCasesLoadingMore extends OrgCasesState {
  final List<OrgCase> currentCases;
  final int nextPage;

  const OrgCasesLoadingMore({
    required this.currentCases,
    required this.nextPage,
  });

  @override
  List<Object?> get props => [currentCases, nextPage];
}

class OrgCasesError extends OrgCasesState {
  final String message;

  const OrgCasesError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrgCaseDeleting extends OrgCasesState {
  final int caseId;

  const OrgCaseDeleting(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class OrgCaseDeleted extends OrgCasesState {
  final int caseId;
  final String message;

  const OrgCaseDeleted(this.caseId, this.message);

  @override
  List<Object?> get props => [caseId, message];
}
