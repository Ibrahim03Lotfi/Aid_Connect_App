import 'package:equatable/equatable.dart';

abstract class GovernorateEvent extends Equatable {
  const GovernorateEvent();

  @override
  List<Object?> get props => [];
}

class FetchGovernoratesEvent extends GovernorateEvent {
  final int? categoryId;

  const FetchGovernoratesEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class SelectGovernorateEvent extends GovernorateEvent {
  final int governorateId;

  const SelectGovernorateEvent(this.governorateId);

  @override
  List<Object?> get props => [governorateId];
}

class FetchMoreCasesEvent extends GovernorateEvent {
  const FetchMoreCasesEvent();
}

class RefreshGovernorateDataEvent extends GovernorateEvent {
  const RefreshGovernorateDataEvent();
}
