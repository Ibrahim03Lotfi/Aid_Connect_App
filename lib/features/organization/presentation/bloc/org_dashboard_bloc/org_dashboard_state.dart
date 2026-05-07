import 'package:equatable/equatable.dart';
import '../../../domain/entities/org_dashboard.dart';

abstract class OrgDashboardState extends Equatable {
  const OrgDashboardState();

  @override
  List<Object?> get props => [];
}

class OrgDashboardInitial extends OrgDashboardState {
  const OrgDashboardInitial();
}

class OrgDashboardLoading extends OrgDashboardState {
  const OrgDashboardLoading();
}

class OrgDashboardLoaded extends OrgDashboardState {
  final OrgDashboard dashboard;

  const OrgDashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class OrgDashboardError extends OrgDashboardState {
  final String message;

  const OrgDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
