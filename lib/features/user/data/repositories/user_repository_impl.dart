import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/http_client.dart';
import '../../domain/entities/case.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/governorate.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/case_model.dart';
import '../models/category_model.dart';
import '../models/governorate_model.dart';

class UserRepositoryImpl implements UserRepository {
  final HttpClient _httpClient;

  UserRepositoryImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/categories',
        fromJsonT: (data) => data as List<dynamic>,
      );
      final categories = (response.data ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(categories);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الفئات'));
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getLatestCases({int page = 1}) async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/cases',
        queryParameters: {'page': page, 'per_page': 10},
        fromJsonT: (data) => data as List<dynamic>,
      );
      final cases = (response.data ?? [])
          .map((e) => CaseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(cases);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الحالات'));
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getCasesByGovernorate(
    int governorateId, {
    int? categoryId,
    int page = 1,
  }) async {
    try {
      final query = <String, dynamic>{
        'governorate_id': governorateId,
        'page': page,
        'per_page': 10,
      };
      if (categoryId != null) {
        query['category_id'] = categoryId;
      }
      final response = await _httpClient.get<List<dynamic>>(
        '/cases',
        queryParameters: query,
        fromJsonT: (data) => data as List<dynamic>,
      );
      final cases = (response.data ?? [])
          .map((e) => CaseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(cases);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الحالات'));
    }
  }

  @override
  Future<Either<Failure, Case>> getCaseDetails(int caseId) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/cases/$caseId',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      if (response.data == null) {
        return Left(NotFoundFailure('الحالة غير موجودة'));
      }
      return Right(CaseModel.fromJson(response.data!));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل تفاصيل الحالة'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementCaseViews(int caseId) async {
    try {
      await _httpClient.post('/cases/$caseId/views', fromJsonT: (data) => data);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث المشاهدات'));
    }
  }

  @override
  Future<Either<Failure, List<Governorate>>> getGovernorates() async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/governorates',
        fromJsonT: (data) => data as List<dynamic>,
      );
      final governorates = (response.data ?? [])
          .map((e) => GovernorateModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(governorates);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل المحافظات'));
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getFavorites() async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/favorites',
        fromJsonT: (data) => data as List<dynamic>,
      );
      final favorites = (response.data ?? [])
          .map((e) => CaseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(favorites);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل المفضلة'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(int caseId) async {
    try {
      await _httpClient.post(
        '/favorites',
        data: {'case_id': caseId},
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في إضافة للمفضلة'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int caseId) async {
    try {
      await _httpClient.delete('/favorites/$caseId', fromJsonT: (data) => data);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في إزالة من المفضلة'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      await _httpClient.put('/user', data: data, fromJsonT: (data) => data);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث الملف الشخصي'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _httpClient.put(
        '/auth/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تغيير كلمة المرور'));
    }
  }
}
