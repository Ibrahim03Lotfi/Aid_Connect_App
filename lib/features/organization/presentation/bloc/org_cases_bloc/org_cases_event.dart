import 'package:equatable/equatable.dart';

abstract class OrgCasesEvent extends Equatable {
  const OrgCasesEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrgCasesEvent extends OrgCasesEvent {
  final int page;
  final String? status;

  const FetchOrgCasesEvent({this.page = 1, this.status});

  @override
  List<Object?> get props => [page, status];
}

class RefreshOrgCasesEvent extends OrgCasesEvent {
  final String? status;

  const RefreshOrgCasesEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class LoadMoreOrgCasesEvent extends OrgCasesEvent {
  final String? status;

  const LoadMoreOrgCasesEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class FilterByStatusEvent extends OrgCasesEvent {
  final String? status;

  const FilterByStatusEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class DeleteCaseEvent extends OrgCasesEvent {
  final int caseId;

  const DeleteCaseEvent(this.caseId);

  @override
  List<Object?> get props => [caseId];
}
