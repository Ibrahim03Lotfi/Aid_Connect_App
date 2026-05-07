import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/org_case.dart';
import '../entities/org_dashboard.dart';
import '../entities/org_profile.dart';

abstract class OrganizationRepository {
  Future<Either<Failure, List<OrgCase>>> getOrganizationCases({
    int page = 1,
    String? status,
  });

  Future<Either<Failure, OrgCase>> getCaseDetails(int caseId);

  Future<Either<Failure, void>> createCase({
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    required List<String> images,
    List<String>? attachments,
  });

  Future<Either<Failure, void>> updateCase({
    required int caseId,
    String? title,
    String? description,
    String? priority,
    List<String>? images,
  });

  Future<Either<Failure, void>> deleteCase(int caseId);

  Future<Either<Failure, OrgDashboard>> getDashboard();

  Future<Either<Failure, OrgProfile>> getProfile();

  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? description,
    String? registrationNumber,
  });
}
