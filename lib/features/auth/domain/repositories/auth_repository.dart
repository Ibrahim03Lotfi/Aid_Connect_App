import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required String role,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> submitOrganizationRequest({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String description,
    required String registrationNumber,
  });

  Future<Either<Failure, User?>> checkAuthStatus();
}
