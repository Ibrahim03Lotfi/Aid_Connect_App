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
  final String? filterStatus;

  const OrgCasesLoaded({
    required this.cases,
    required this.currentPage,
    this.hasMore = true,
    this.filterStatus,
  });

  OrgCasesLoaded copyWith({
    List<OrgCase>? cases,
    int? currentPage,
    bool? hasMore,
    String? filterStatus,
  }) {
    return OrgCasesLoaded(
      cases: cases ?? this.cases,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [cases, currentPage, hasMore, filterStatus];
}

class OrgCasesLoadingMore extends OrgCasesState {
  final List<OrgCase> currentCases;
  final int nextPage;
  final String? filterStatus;

  const OrgCasesLoadingMore({
    required this.currentCases,
    required this.nextPage,
    this.filterStatus,
  });

  @override
  List<Object?> get props => [currentCases, nextPage, filterStatus];
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
