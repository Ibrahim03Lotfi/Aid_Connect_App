import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/repositories/organization_repository.dart';
import 'org_dashboard_event.dart';
import 'org_dashboard_state.dart';

class OrgDashboardBloc extends Bloc<OrgDashboardEvent, OrgDashboardState> {
  final OrganizationRepository _repository;

  OrgDashboardBloc({required OrganizationRepository repository})
    : _repository = repository,
      super(const OrgDashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<OrgDashboardState> emit,
  ) async {
    emit(const OrgDashboardLoading());
    final result = await _repository.getDashboard();
    result.fold(
      (failure) => emit(OrgDashboardError(_mapFailureToMessage(failure))),
      (dashboard) => emit(OrgDashboardLoaded(dashboard)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message;
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
