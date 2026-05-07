import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../organization/domain/entities/org_case.dart';
import '../../../user/domain/entities/case.dart';
import '../entities/volunteer_case.dart';

abstract class VolunteerRepository {
  // Available cases for volunteers to apply
  Future<Either<Failure, List<VolunteerCase>>> getAvailableCases({
    int page = 1,
    String? category,
    String? governorate,
  });

  // Cases the volunteer has applied to
  Future<Either<Failure, List<VolunteerApplication>>> getMyApplications({
    int page = 1,
    String? status,
  });

  // Apply to a case
  Future<Either<Failure, void>> applyToCase(int caseId);

  // Cancel application
  Future<Either<Failure, void>> cancelApplication(int applicationId);

  // Get case details
  Future<Either<Failure, VolunteerCase>> getCaseDetails(int caseId);

  // Update volunteer profile
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    List<String>? skills,
  });

  // Get volunteer profile
  Future<Either<Failure, Map<String, dynamic>>> getProfile();

  // Change account password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Volunteer dashboard data (urgent count + recent activity)
  Future<Either<Failure, Map<String, dynamic>>> getDashboard();

  // Searchable feed of volunteer-published cases (approved only)
  Future<Either<Failure, List<Case>>> getVolunteerFeed({
    int page = 1,
    String? query,
  });

  // Volunteer-owned aid cases (CRUD like organization)
  Future<Either<Failure, List<OrgCase>>> getMyCases({
    int page = 1,
  });

  Future<Either<Failure, void>> createMyCase({
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    List<String> imagePaths = const [],
  });

  Future<Either<Failure, void>> updateMyCase({
    required int caseId,
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    List<String> existingImageUrls = const [],
    List<String> imagePaths = const [],
  });

  Future<Either<Failure, void>> deleteMyCase(int caseId);
}
