import 'package:equatable/equatable.dart';

abstract class OrgDashboardEvent extends Equatable {
  const OrgDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends OrgDashboardEvent {
  const LoadDashboard();
}
