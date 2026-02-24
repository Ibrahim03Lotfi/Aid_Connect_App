import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../services/local_storage_service.dart';
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
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'role': role,
        },
        fromJsonT: (data) => data,
      );

      if (response.success) {
        final userModel = UserModel.fromJson(response.data!['user']);
        final token = response.data!['token'];
        
        await _localStorage.saveToken(token);
        await _localStorage.saveUserData(jsonEncode(userModel.toJson()));
        
        return Right(userModel);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
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
      final response = await _dioClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
        fromJsonT: (data) => data,
      );

      if (response.success) {
        final userModel = UserModel.fromJson(response.data!['user']);
        final token = response.data!['token'];
        
        await _localStorage.saveToken(token);
        await _localStorage.saveUserData(jsonEncode(userModel.toJson()));
        
        return Right(userModel);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on Failure catch (failure) {
      return Left(failure);
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
    try {
      final response = await _dioClient.post(
        '/auth/organization-request',
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
  Future<Either<Failure, User?>> checkAuthStatus() async {
    try {
      final token = await _localStorage.getToken();
      final userData = _localStorage.getUserData();

      if (token == null || userData == null) {
        return const Right(null);
      }

      // Verify token with backend
      final response = await _dioClient.get(
        '/auth/me',
        fromJsonT: (data) => data,
      );

      if (response.success) {
        final userModel = UserModel.fromJson(response.data!);
        await _localStorage.saveUserData(jsonEncode(userModel.toJson()));
        return Right(userModel);
      } else {
        await _localStorage.clearAll();
        return const Right(null);
      }
    } on Failure {
      await _localStorage.clearAll();
      return const Right(null);
    }
  }
}
