import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
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
}
