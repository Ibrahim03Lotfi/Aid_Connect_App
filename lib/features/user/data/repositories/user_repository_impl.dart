import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
  static const Set<String> _syrianGovernorates = {
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'الرقة',
    'دير الزور',
    'الحسكة',
    'درعا',
    'السويداء',
    'القنيطرة',
  };

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
  Future<Either<Failure, List<Case>>> getAllCases({int page = 1}) async {
    try {
      log('Fetching all cases - page: $page');
      final response = await _httpClient.get<List<dynamic>>(
        '/cases',
        queryParameters: {'page': page, 'per_page': 10},
        fromJsonT: (data) {
          log('fromJsonT received data type: ${data.runtimeType}');
          return data as List<dynamic>;
        },
      );
      log('Response success: ${response.success}');
      log('Response message: ${response.message}');
      log('Response data type: ${response.data?.runtimeType}');
      
      final data = response.data ?? [];
      log('Cases count: ${data.length}');
      
      if (data.isEmpty) {
        log('No cases found, returning empty list');
        return Right([]);
      }
      
      final cases = <Case>[];
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        log('Parsing case $i, type: ${item.runtimeType}');
        try {
          cases.add(CaseModel.fromJson(item as Map<String, dynamic>));
        } catch (e2, st) {
          log('Error parsing case $i: $e2\n$st');
          log('Case data: $item');
          // Continue with other cases instead of failing completely
        }
      }
      
      log('Successfully parsed ${cases.length} cases');
      return Right(cases);
    } on Failure catch (failure) {
      log('Failure caught: $failure');
      return Left(failure);
    } catch (e, stackTrace) {
      log('Error in getAllCases: $e\n$stackTrace');
      return Left(ServerFailure('فشل في تحميل الحالات'));
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getCasesByCategory(
    int categoryId, {
    int page = 1,
  }) async {
    try {
      debugPrint('UserRepository: getCasesByCategory called with categoryId: $categoryId, page: $page');
      log('Fetching cases by category: $categoryId, page: $page');
      final response = await _httpClient.get<List<dynamic>>(
        '/cases',
        queryParameters: {'category_id': categoryId, 'page': page, 'per_page': 10},
        fromJsonT: (data) {
          log('Response data type: ${data.runtimeType}');
          return data as List<dynamic>;
        },
      );
      log('Response success: ${response.success}');
      log('Response message: ${response.message}');
      final data = response.data ?? [];
      debugPrint('UserRepository: Cases count: ${data.length}');
      log('Cases count: ${data.length}');
      
      final cases = <Case>[];
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        debugPrint('UserRepository: Parsing case $i, type: ${item.runtimeType}');
        log('Parsing case $i, type: ${item.runtimeType}');
        try {
          cases.add(CaseModel.fromJson(item as Map<String, dynamic>));
          debugPrint('UserRepository: Successfully parsed case $i');
        } catch (e2, st) {
          debugPrint('UserRepository: Error parsing case $i: $e2');
          log('Error parsing case $i: $e2\n$st');
          log('Case data: $item');
          // Continue with other cases instead of failing completely
        }
      }
      
      debugPrint('UserRepository: Successfully parsed ${cases.length} cases');
      log('Successfully parsed ${cases.length} cases');
      return Right(cases);
    } on Failure catch (failure) {
      debugPrint('UserRepository: Failure caught: $failure');
      log('Failure caught: $failure');
      return Left(failure);
    } catch (e, stackTrace) {
      debugPrint('UserRepository: Error in getCasesByCategory: $e\n$stackTrace');
      log('Error in getCasesByCategory: $e\n$stackTrace');
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
          .where((g) => _syrianGovernorates.contains(g.name.trim()))
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
