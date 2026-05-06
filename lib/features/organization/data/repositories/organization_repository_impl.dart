import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/http_client.dart';
import '../../domain/entities/org_case.dart';
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
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
