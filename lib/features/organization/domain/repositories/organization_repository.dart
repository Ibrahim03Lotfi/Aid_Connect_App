import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/org_case.dart';

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
}
