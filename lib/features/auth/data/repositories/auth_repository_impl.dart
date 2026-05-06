import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final LocalStorageService _localStorage;

  AuthRepositoryImpl({
    required DioClient dioClient,
    required LocalStorageService localStorage,
  }) : _dioClient = dioClient,
       _localStorage = localStorage;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password, 'role': role},
        fromJsonT: (data) => data as Map<String, dynamic>,
      );

      final data = response.data!;
      final token = data['token'] as String?;
      if (token == null) {
        return Left(ServerFailure('لم يتم استلام رمز المصادقة'));
      }

      await _localStorage.saveToken(token);
      await _localStorage.saveUserData(jsonEncode(data));
      await _localStorage.saveRole(data['role'] as String? ?? role);

      return Right(UserModel.fromJson(data));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تسجيل الدخول'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
        fromJsonT: (data) => data as Map<String, dynamic>,
      );

      final data = response.data!;
      final token = data['token'] as String?;
      if (token == null) {
        return Left(ServerFailure('لم يتم استلام رمز المصادقة'));
      }

      await _localStorage.saveToken(token);
      await _localStorage.saveUserData(jsonEncode(data));
      await _localStorage.saveRole(data['role'] as String? ?? UserRoles.user);

      return Right(UserModel.fromJson(data));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء إنشاء الحساب'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await _localStorage.getToken();
      if (token != null) {
        await _dioClient.post('/auth/logout', fromJsonT: (data) => data);
      }
      await _localStorage.clearAll();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> submitOrganizationRequest({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String description,
    required String registrationNumber,
  }) async {
    try {
      await _dioClient.post(
        '/organization/request',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'description': description,
          'registration_number': registrationNumber,
        },
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء إرسال الطلب'));
    }
  }

  @override
  Future<Either<Failure, User?>> checkAuthStatus() async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Right(null);
      }

      final response = await _dioClient.get<Map<String, dynamic>>(
        '/auth/me',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );

      if (response.data != null) {
        return Right(UserModel.fromJson(response.data!));
      }
      return const Right(null);
    } on Failure catch (failure) {
      await _localStorage.clearAll();
      return Left(failure);
    } catch (e) {
      await _localStorage.clearAll();
      return const Right(null);
    }
  }
}
