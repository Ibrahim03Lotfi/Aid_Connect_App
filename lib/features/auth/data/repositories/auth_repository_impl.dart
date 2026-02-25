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
  })  : _dioClient = dioClient,
        _localStorage = localStorage;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // STATIC/MOCK LOGIN - accepts any credentials, immediate response
    final mockUser = UserModel(
      id: 1,
      name: role == UserRoles.user ? 'مستخدم تجريبي' : 
            role == UserRoles.organization ? 'منظمة تجريبية' : 'متطوع تجريبي',
      email: email.isNotEmpty ? email : 'demo@example.com',
      phone: '0123456789',
      role: role,
      isActive: true,
    );
    
    await _localStorage.saveToken('mock_token_12345');
    await _localStorage.saveUserData(jsonEncode(mockUser.toJson()));
    await _localStorage.saveRole(role);
    
    return Right(mockUser);
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // STATIC/MOCK REGISTER - accepts any data
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockUser = UserModel(
        id: 1,
        name: name.isNotEmpty ? name : 'مستخدم جديد',
        email: email.isNotEmpty ? email : 'new@example.com',
        phone: phone.isNotEmpty ? phone : '0123456789',
        role: UserRoles.user,
        isActive: true,
      );
      
      await _localStorage.saveToken('mock_token_register');
      await _localStorage.saveUserData(jsonEncode(mockUser.toJson()));
      await _localStorage.saveRole(UserRoles.user);
      
      return Right(mockUser);
    } catch (e) {
      return Left(ServerFailure('خطأ في إنشاء الحساب'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await _localStorage.getToken();
      if (token != null) {
        await _dioClient.post(
          '/auth/logout',
          fromJsonT: (data) => data,
        );
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
    // STATIC/MOCK - just simulate success
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('خطأ في إرسال الطلب'));
    }
  }

  @override
  Future<Either<Failure, User?>> checkAuthStatus() async {
    // STATIC/MOCK - just check local storage
    try {
      final token = await _localStorage.getToken();
      final userData = _localStorage.getUserData();

      if (token == null || userData == null) {
        return const Right(null);
      }

      // Return mock user from local storage (no API call)
      final userModel = UserModel.fromJson(jsonDecode(userData));
      return Right(userModel);
    } catch (e) {
      await _localStorage.clearAll();
      return const Right(null);
    }
  }
}
