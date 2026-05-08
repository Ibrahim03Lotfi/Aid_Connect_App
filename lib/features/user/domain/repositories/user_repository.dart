import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/case.dart';
import '../entities/category.dart';
import '../entities/governorate.dart';

abstract class UserRepository {
  // Categories
  Future<Either<Failure, List<Category>>> getCategories();

  // Cases
  Future<Either<Failure, List<Case>>> getLatestCases({int page = 1});
  Future<Either<Failure, List<Case>>> getAllCases({int page = 1});
  Future<Either<Failure, List<Case>>> getCasesByCategory(
    int categoryId, {
    int page = 1,
  });
  Future<Either<Failure, List<Case>>> getCasesByGovernorate(
    int governorateId, {
    int? categoryId,
    int page = 1,
  });
  Future<Either<Failure, Case>> getCaseDetails(int caseId);
  Future<Either<Failure, void>> incrementCaseViews(int caseId);

  // Governorates
  Future<Either<Failure, List<Governorate>>> getGovernorates();

  // Favorites
  Future<Either<Failure, List<Case>>> getFavorites();
  Future<Either<Failure, void>> addToFavorites(int caseId);
  Future<Either<Failure, void>> removeFromFavorites(int caseId);

  // Profile
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
