import 'package:equatable/equatable.dart';

abstract class OrgCasesEvent extends Equatable {
  const OrgCasesEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrgCasesEvent extends OrgCasesEvent {
  final int page;

  const FetchOrgCasesEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class RefreshOrgCasesEvent extends OrgCasesEvent {
  const RefreshOrgCasesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoreOrgCasesEvent extends OrgCasesEvent {
  const LoadMoreOrgCasesEvent();

  @override
  List<Object?> get props => [];
}

class DeleteCaseEvent extends OrgCasesEvent {
  final int caseId;

  const DeleteCaseEvent(this.caseId);

  @override
  List<Object?> get props => [caseId];
}
