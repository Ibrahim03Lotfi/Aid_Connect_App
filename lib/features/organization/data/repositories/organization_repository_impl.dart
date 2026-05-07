import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/http_client.dart';
import '../../domain/entities/org_case.dart';
import '../../domain/entities/org_dashboard.dart';
import '../../domain/entities/org_profile.dart';
import '../../domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final HttpClient _httpClient;

  OrganizationRepositoryImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  @override
  Future<Either<Failure, List<OrgCase>>> getOrganizationCases({
    int page = 1,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': 10};
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }
      final response = await _httpClient.get<List<dynamic>>(
        '/organization/cases',
        queryParameters: query,
        fromJsonT: (data) => data as List<dynamic>,
      );
      final items = (response.data ?? [])
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل حالات المنظمة'));
    }
  }

  @override
  Future<Either<Failure, OrgCase>> getCaseDetails(int caseId) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/organization/cases/$caseId',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      if (response.data == null) {
        return Left(NotFoundFailure('الحالة غير موجودة'));
      }
      return Right(_fromJson(response.data!));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل تفاصيل الحالة'));
    }
  }

  @override
  Future<Either<Failure, void>> createCase({
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    required List<String> images,
    List<String>? attachments,
  }) async {
    try {
      await _httpClient.post(
        '/organization/cases',
        data: {
          'title': title,
          'description': description,
          'category_id': categoryId,
          'governorate_id': governorateId,
          'priority': priority,
          'images': images,
          'attachments': attachments ?? <String>[],
        },
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في إنشاء الحالة'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCase({
    required int caseId,
    String? title,
    String? description,
    String? priority,
    List<String>? images,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (description != null) payload['description'] = description;
      if (priority != null) payload['priority'] = priority;
      if (images != null) payload['images'] = images;

      await _httpClient.put(
        '/organization/cases/$caseId',
        data: payload,
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحديث الحالة'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCase(int caseId) async {
    try {
      await _httpClient.delete(
        '/organization/cases/$caseId',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في حذف الحالة'));
    }
  }

  OrgCase _fromJson(Map<String, dynamic> json) {
    return OrgCase(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      category: json['category'] ?? '',
      governorate: json['governorate'] ?? '',
      views: json['views'] ?? 0,
      donationsCount: json['donations_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      thumbnail: json['thumbnail'],
      rejectionReason: json['rejection_reason'],
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  Future<Either<Failure, OrgDashboard>> getDashboard() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/organization/dashboard',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      if (response.data == null) {
        return Left(ServerFailure('فشل في تحميل لوحة التحكم'));
      }
      return Right(_fromJsonDashboard(response.data!));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل لوحة التحكم'));
    }
  }

  @override
  Future<Either<Failure, OrgProfile>> getProfile() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/organization/profile',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      if (response.data == null) {
        return Left(ServerFailure('فشل في تحميل الملف الشخصي'));
      }
      return Right(_fromJsonProfile(response.data!));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل الملف الشخصي'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? description,
    String? registrationNumber,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null && name.isNotEmpty) payload['name'] = name;
      if (phone != null && phone.isNotEmpty) payload['phone'] = phone;
      if (address != null && address.isNotEmpty) payload['address'] = address;
      if (description != null && description.isNotEmpty) {
        payload['bio'] = description;
      }
      if (registrationNumber != null && registrationNumber.isNotEmpty) {
        payload['registration_number'] = registrationNumber;
      }

      if (payload.isEmpty) {
        return const Left(ServerFailure('لم يتم إدخال أي تغييرات'));
      }

      await _httpClient.put(
        '/organization/profile',
        data: payload,
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث الملف الشخصي: ${e.toString()}'));
    }
  }

  OrgDashboard _fromJsonDashboard(Map<String, dynamic> json) {
    return OrgDashboard(
      pendingCasesCount: json['pending_cases_count'] ?? 0,
      approvedCasesCount: json['approved_cases_count'] ?? 0,
      rejectedCasesCount: json['rejected_cases_count'] ?? 0,
      totalCasesCount: json['total_cases_count'] ?? 0,
      totalDonations: json['total_donations'] ?? 0,
    );
  }

  OrgProfile _fromJsonProfile(Map<String, dynamic> json) {
    return OrgProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      joinedAt: json['joined_at'] ?? '',
    );
  }
}
