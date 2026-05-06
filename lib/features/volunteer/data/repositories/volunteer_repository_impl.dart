import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/failures.dart';
import '../../../../core/network/http_client.dart';
import '../../../organization/domain/entities/org_case.dart';
import '../../../user/data/models/case_model.dart';
import '../../../user/domain/entities/case.dart';
import '../../domain/entities/volunteer_case.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {
  final HttpClient _httpClient;

  VolunteerRepositoryImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  @override
  Future<Either<Failure, List<VolunteerCase>>> getAvailableCases({
    int page = 1,
    String? category,
    String? governorate,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': 10};
      if (category != null && category.isNotEmpty) query['category'] = category;
      if (governorate != null && governorate.isNotEmpty) {
        query['governorate'] = governorate;
      }
      final response = await _httpClient.get<List<dynamic>>(
        '/volunteer/cases',
        queryParameters: query,
        fromJsonT: (data) => data as List<dynamic>,
      );
      final cases = (response.data ?? [])
          .map((e) => _caseFromJson(e as Map<String, dynamic>))
          .toList();
      return Right(cases);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل حالات التطوع'));
    }
  }

  @override
  Future<Either<Failure, List<VolunteerApplication>>> getMyApplications({
    int page = 1,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': 10};
      if (status != null && status.isNotEmpty) query['status'] = status;
      final response = await _httpClient.get<List<dynamic>>(
        '/volunteer/applications',
        queryParameters: query,
        fromJsonT: (data) => data as List<dynamic>,
      );
      final applications = (response.data ?? [])
          .map((e) => _applicationFromJson(e as Map<String, dynamic>))
          .toList();
      return Right(applications);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل طلبات التطوع'));
    }
  }

  @override
  Future<Either<Failure, void>> applyToCase(int caseId) async {
    try {
      await _httpClient.post(
        '/volunteer/apply/$caseId',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في إرسال طلب التطوع'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelApplication(int applicationId) async {
    try {
      await _httpClient.delete(
        '/volunteer/applications/$applicationId',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في إلغاء الطلب'));
    }
  }

  @override
  Future<Either<Failure, VolunteerCase>> getCaseDetails(int caseId) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/volunteer/cases/$caseId',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      if (response.data == null) {
        return Left(NotFoundFailure('الحالة غير موجودة'));
      }
      return Right(_caseFromJson(response.data!));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل تفاصيل الحالة'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    List<String>? skills,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (phone != null) payload['phone'] = phone;
      if (bio != null) payload['bio'] = bio;
      if (skills != null) payload['skills'] = skills;
      await _httpClient.put(
        '/volunteer/profile',
        data: payload,
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحديث الملف الشخصي'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/volunteer/profile',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      final data = response.data ?? <String, dynamic>{};
      return Right({
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'phone': data['phone'] ?? '',
        'bio': data['bio'] ?? '',
        'skills': data['skills'] ?? <String>[],
        'joinedAt': data['joined_at'] ?? '',
        'completedCases': data['completed_cases'] ?? 0,
        'activeCases': data['active_cases'] ?? 0,
      });
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل الملف الشخصي'));
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
    } catch (_) {
      return Left(ServerFailure('فشل في تغيير كلمة المرور'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/volunteer/dashboard',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      return Right(response.data ?? <String, dynamic>{});
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل لوحة المتطوع'));
    }
  }

  @override
  Future<Either<Failure, List<Case>>> getVolunteerFeed({
    int page = 1,
    String? query,
  }) async {
    try {
      final qp = <String, dynamic>{'page': page, 'per_page': 10};
      if (query != null && query.trim().isNotEmpty) qp['q'] = query.trim();
      final response = await _httpClient.get<List<dynamic>>(
        '/volunteer/feed',
        queryParameters: qp,
        fromJsonT: (data) => data as List<dynamic>,
      );
      final items = (response.data ?? [])
          .map((e) => CaseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل الحالات'));
    }
  }

  @override
  Future<Either<Failure, List<OrgCase>>> getMyCases({
    int page = 1,
  }) async {
    try {
      final qp = <String, dynamic>{'page': page, 'per_page': 10};
      final response = await _httpClient.get<List<dynamic>>(
        '/volunteer/my-cases',
        queryParameters: qp,
        fromJsonT: (data) => data as List<dynamic>,
      );
      final items = (response.data ?? []).map((e) {
        final json = e as Map<String, dynamic>;
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
          rejectionReason: json['rejection_reason'],
          images: const [],
        );
      }).toList();
      return Right(items);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تحميل حالاتك'));
    }
  }

  @override
  Future<Either<Failure, void>> createMyCase({
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    List<String> imagePaths = const [],
  }) async {
    try {
      final files = imagePaths
          .map((p) => http.MultipartFile.fromPath('images[]', p))
          .toList();
      await _httpClient.postMultipart(
        '/volunteer/my-cases',
        fields: {
          'title': title,
          'description': description,
          'category_id': categoryId.toString(),
          'governorate_id': governorateId.toString(),
          'priority': priority,
        },
        files: await Future.wait(files),
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
  Future<Either<Failure, void>> updateMyCase({
    required int caseId,
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    List<String> imagePaths = const [],
  }) async {
    try {
      final files = imagePaths
          .map((p) => http.MultipartFile.fromPath('images[]', p))
          .toList();
      await _httpClient.putMultipart(
        '/volunteer/my-cases/$caseId',
        fields: {
          'title': title,
          'description': description,
          'category_id': categoryId.toString(),
          'governorate_id': governorateId.toString(),
          'priority': priority,
        },
        files: await Future.wait(files),
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في تعديل الحالة'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMyCase(int caseId) async {
    try {
      await _httpClient.delete(
        '/volunteer/my-cases/$caseId',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure('فشل في حذف الحالة'));
    }
  }

  VolunteerCase _caseFromJson(Map<String, dynamic> json) {
    return VolunteerCase(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      governorate: json['governorate'] ?? '',
      priority: json['priority'] ?? 'medium',
      organizationName: json['organization_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      volunteersNeeded: json['volunteers_needed'] ?? 0,
      volunteersApplied: json['volunteers_applied'] ?? 0,
      thumbnail: json['thumbnail'],
      isUrgent: json['is_urgent'] ?? false,
    );
  }

  VolunteerApplication _applicationFromJson(Map<String, dynamic> json) {
    return VolunteerApplication(
      id: json['id'] ?? 0,
      caseId: json['case_id'] ?? 0,
      caseTitle: json['case_title'] ?? '',
      status: json['status'] ?? 'pending',
      appliedAt: json['applied_at'] != null
          ? DateTime.parse(json['applied_at'])
          : DateTime.now(),
      organizationName: json['organization_name'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
