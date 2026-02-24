import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeDataEvent extends HomeEvent {
  const FetchHomeDataEvent();
}

class FetchMoreCasesEvent extends HomeEvent {
  const FetchMoreCasesEvent();
}

class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}

class CategorySelectedEvent extends HomeEvent {
  final int categoryId;

  const CategorySelectedEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
