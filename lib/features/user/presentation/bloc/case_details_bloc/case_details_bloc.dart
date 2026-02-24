import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/user_repository.dart';
import 'case_details_event.dart';
import 'case_details_state.dart';

class CaseDetailsBloc extends Bloc<CaseDetailsEvent, CaseDetailsState> {
  final UserRepository _userRepository;

  CaseDetailsBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const CaseDetailsInitial()) {
    on<FetchCaseDetailsEvent>(_onFetchCaseDetails);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onFetchCaseDetails(
    FetchCaseDetailsEvent event,
    Emitter<CaseDetailsState> emit,
  ) async {
    emit(const CaseDetailsLoading());

    final result = await _userRepository.getCaseDetails(event.caseId);

    result.fold(
      (failure) => emit(CaseDetailsError(_mapFailureToMessage(failure))),
      (caseItem) {
        emit(CaseDetailsLoaded(
          caseItem: caseItem,
          isFavorited: caseItem.isFavorited,
        ));
      },
    );

    // Increment views (fire and forget)
    await _userRepository.incrementCaseViews(event.caseId);
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<CaseDetailsState> emit,
  ) async {
    if (state is CaseDetailsLoaded) {
      final currentState = state as CaseDetailsLoaded;
      
      // Optimistic update
      emit(currentState.copyWith(
        isFavorited: !event.isCurrentlyFavorited,
      ));

      if (event.isCurrentlyFavorited) {
        await _userRepository.removeFromFavorites(event.caseId);
      } else {
        await _userRepository.addToFavorites(event.caseId);
      }
    }
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType.toString()) {
      case 'ServerFailure':
        return 'حدث خطأ في الخادم';
      case 'NetworkFailure':
        return 'لا يوجد اتصال بالإنترنت';
      case 'NotFoundFailure':
        return 'الحالة غير موجودة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
