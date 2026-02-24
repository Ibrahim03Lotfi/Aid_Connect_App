import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/case.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/governorate.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/case_model.dart';
import '../models/category_model.dart';
import '../models/governorate_model.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient _dioClient;

  UserRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final response = await _dioClient.get(
        '/categories',
        fromJsonT: (data) => data,
      );

      if (response.success && response.data != null) {
        final categories = (response.data as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        return Right(categories);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getLatestCases({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        '/cases/latest',
        queryParameters: {'page': page},
        fromJsonT: (data) => data,
      );

      if (response.success && response.data != null) {
        final cases = (response.data as List)
            .map((json) => CaseModel.fromJson(json))
            .toList();
        return Right(cases);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getCasesByGovernorate(
    int governorateId, {
    int? categoryId,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'governorate_id': governorateId,
        'page': page,
        if (categoryId != null) 'category_id': categoryId,
      };

      final response = await _dioClient.get(
        '/cases',
        queryParameters: queryParams,
        fromJsonT: (data) => data,
      );

      if (response.success && response.data != null) {
        final cases = (response.data as List)
            .map((json) => CaseModel.fromJson(json))
            .toList();
        return Right(cases);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Case>> getCaseDetails(int caseId) async {
    try {
      final response = await _dioClient.get(
        '/cases/$caseId',
        fromJsonT: (data) => data,
      );

      if (response.success && response.data != null) {
        return Right(CaseModel.fromJson(response.data!));
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> incrementCaseViews(int caseId) async {
    try {
      await _dioClient.post(
        '/cases/$caseId/view',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Governorate>>> getGovernorates() async {
    try {
      final response = await _dioClient.get(
        '/governorates',
        fromJsonT: (data) => data,
      );

      if (response.success && response.data != null) {
        final governorates = (response.data as List)
            .map((json) => GovernorateModel.fromJson(json))
            .toList();
        return Right(governorates);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getFavorites() async {
    try {
      final response = await _dioClient.get(
        '/favorites',
        fromJsonT: (data) => data,
      );

      if (response.success && response.data != null) {
        final cases = (response.data as List)
            .map((json) => CaseModel.fromJson(json))
            .toList();
        return Right(cases);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(int caseId) async {
    try {
      await _dioClient.post(
        '/favorites',
        data: {'case_id': caseId},
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int caseId) async {
    try {
      await _dioClient.delete(
        '/favorites/$caseId',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
      };

      final response = await _dioClient.put(
        '/profile',
        data: data,
        fromJsonT: (data) => data,
      );

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.put(
        '/profile/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        fromJsonT: (data) => data,
      );

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
    }
  }
}
