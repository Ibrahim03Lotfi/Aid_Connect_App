import 'package:equatable/equatable.dart';

class OrgDashboard extends Equatable {
  final int pendingCasesCount;
  final int approvedCasesCount;
  final int rejectedCasesCount;
  final int totalCasesCount;
  final int totalDonations;

  const OrgDashboard({
    required this.pendingCasesCount,
    required this.approvedCasesCount,
    required this.rejectedCasesCount,
    required this.totalCasesCount,
    required this.totalDonations,
  });

  @override
  List<Object?> get props => [
        pendingCasesCount,
        approvedCasesCount,
        rejectedCasesCount,
        totalCasesCount,
        totalDonations,
      ];
}
