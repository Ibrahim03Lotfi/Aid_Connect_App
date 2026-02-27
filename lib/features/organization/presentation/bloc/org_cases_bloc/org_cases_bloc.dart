import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/repositories/organization_repository.dart';
import 'org_cases_event.dart';
import 'org_cases_state.dart';

class OrgCasesBloc extends Bloc<OrgCasesEvent, OrgCasesState> {
  final OrganizationRepository _repository;
  int _currentPage = 1;
  String? _currentFilter;

  OrgCasesBloc({required OrganizationRepository repository})
      : _repository = repository,
        super(const OrgCasesInitial()) {
    on<FetchOrgCasesEvent>(_onFetchCases);
    on<RefreshOrgCasesEvent>(_onRefreshCases);
    on<LoadMoreOrgCasesEvent>(_onLoadMoreCases);
    on<FilterByStatusEvent>(_onFilterByStatus);
    on<DeleteCaseEvent>(_onDeleteCase);
  }

  Future<void> _onFetchCases(
    FetchOrgCasesEvent event,
    Emitter<OrgCasesState> emit,
  ) async {
    emit(const OrgCasesLoading());

    _currentPage = event.page;
    _currentFilter = event.status;

    final result = await _repository.getOrganizationCases(
      page: _currentPage,
      status: _currentFilter,
    );

    result.fold(
      (failure) => emit(OrgCasesError(_mapFailureToMessage(failure))),
      (cases) => emit(OrgCasesLoaded(
        cases: cases,
        currentPage: _currentPage,
        hasMore: cases.length >= 10,
        filterStatus: _currentFilter,
      )),
    );
  }

  Future<void> _onRefreshCases(
    RefreshOrgCasesEvent event,
    Emitter<OrgCasesState> emit,
  ) async {
    _currentPage = 1;
    _currentFilter = event.status;

    final result = await _repository.getOrganizationCases(
      page: 1,
      status: _currentFilter,
    );

    result.fold(
      (failure) => emit(OrgCasesError(_mapFailureToMessage(failure))),
      (cases) => emit(OrgCasesLoaded(
        cases: cases,
        currentPage: 1,
        hasMore: cases.length >= 10,
        filterStatus: _currentFilter,
      )),
    );
  }

  Future<void> _onLoadMoreCases(
    LoadMoreOrgCasesEvent event,
    Emitter<OrgCasesState> emit,
  ) async {
    if (state is OrgCasesLoaded) {
      final currentState = state as OrgCasesLoaded;
      if (!currentState.hasMore) return;

      emit(OrgCasesLoadingMore(
        currentCases: currentState.cases,
        nextPage: currentState.currentPage + 1,
        filterStatus: _currentFilter,
      ));

      final result = await _repository.getOrganizationCases(
        page: currentState.currentPage + 1,
        status: _currentFilter,
      );

      result.fold(
        (failure) => emit(OrgCasesError(_mapFailureToMessage(failure))),
        (newCases) {
          _currentPage = currentState.currentPage + 1;
          emit(OrgCasesLoaded(
            cases: [...currentState.cases, ...newCases],
            currentPage: _currentPage,
            hasMore: newCases.length >= 10,
            filterStatus: _currentFilter,
          ));
        },
      );
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatusEvent event,
    Emitter<OrgCasesState> emit,
  ) async {
    emit(const OrgCasesLoading());

    _currentPage = 1;
    _currentFilter = event.status;

    final result = await _repository.getOrganizationCases(
      page: 1,
      status: _currentFilter,
    );

    result.fold(
      (failure) => emit(OrgCasesError(_mapFailureToMessage(failure))),
      (cases) => emit(OrgCasesLoaded(
        cases: cases,
        currentPage: 1,
        hasMore: cases.length >= 10,
        filterStatus: _currentFilter,
      )),
    );
  }

  Future<void> _onDeleteCase(
    DeleteCaseEvent event,
    Emitter<OrgCasesState> emit,
  ) async {
    if (state is OrgCasesLoaded) {
      final currentState = state as OrgCasesLoaded;

      emit(OrgCaseDeleting(event.caseId));

      final result = await _repository.deleteCase(event.caseId);

      result.fold(
        (failure) => emit(OrgCasesError(_mapFailureToMessage(failure))),
        (_) {
          final updatedCases = currentState.cases
              .where((c) => c.id != event.caseId)
              .toList();
          emit(OrgCasesLoaded(
            cases: updatedCases,
            currentPage: currentState.currentPage,
            hasMore: currentState.hasMore,
            filterStatus: currentState.filterStatus,
          ));
          emit(OrgCaseDeleted(event.caseId, 'تم حذف الحالة بنجاح'));
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'حدث خطأ في الخادم';
      case NetworkFailure:
        return 'لا يوجد اتصال بالإنترنت';
      case NotFoundFailure:
        return 'الحالة غير موجودة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
