import 'package:equatable/equatable.dart';
import '../../../domain/entities/case.dart';

abstract class CaseDetailsState extends Equatable {
  const CaseDetailsState();

  @override
  List<Object?> get props => [];
}

class CaseDetailsInitial extends CaseDetailsState {
  const CaseDetailsInitial();
}

class CaseDetailsLoading extends CaseDetailsState {
  const CaseDetailsLoading();
}

class CaseDetailsLoaded extends CaseDetailsState {
  final Case caseItem;
  final bool isFavorited;

  const CaseDetailsLoaded({
    required this.caseItem,
    this.isFavorited = false,
  });

  CaseDetailsLoaded copyWith({
    Case? caseItem,
    bool? isFavorited,
  }) {
    return CaseDetailsLoaded(
      caseItem: caseItem ?? this.caseItem,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  List<Object?> get props => [caseItem, isFavorited];
}

class CaseDetailsError extends CaseDetailsState {
  final String message;

  const CaseDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ToggleFavoriteSuccess extends CaseDetailsState {
  final bool isFavorited;

  const ToggleFavoriteSuccess(this.isFavorited);

  @override
  List<Object?> get props => [isFavorited];
}
