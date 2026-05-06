import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/http_client.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final HttpClient _httpClient;
  NotificationRepositoryImpl(this._httpClient);

  @override
  Future<Either<Failure, List<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _httpClient.get<List<dynamic>>(
        '/notifications',
        queryParameters: {'page': page, 'per_page': limit},
        fromJsonT: (data) => data as List<dynamic>,
      );
      final notifications = (response.data ?? [])
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(notifications);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, NotificationStats>> getNotificationStats() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/notifications/stats',
        fromJsonT: (data) => data as Map<String, dynamic>,
      );
      final stats = response.data ?? <String, dynamic>{};
      return Right(NotificationStats(
        total: stats['total'] ?? 0,
        unread: stats['unread'] ?? 0,
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل إحصائيات الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    try {
      await _httpClient.post(
        '/notifications/$notificationId/read',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث حالة الإشعار'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _httpClient.post(
        '/notifications/read-all',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث حالة الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await _httpClient.delete(
        '/notifications/$notificationId',
        fromJsonT: (data) => data,
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('فشل في حذف الإشعار'));
    }
  }

  @override
  Future<Either<Failure, void>> showLocalNotification({
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    required DateTime scheduledTime,
  }) async {
    return const Right(null);
  }

  Notification _fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _mapType(json['type']?.toString()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      relatedCaseId: json['related_case_id'],
      relatedEntityName: json['related_entity_name'],
      rejectionReason: json['rejection_reason'],
    );
  }

  NotificationType _mapType(String? type) {
    switch (type) {
      case 'case_approved':
        return NotificationType.caseApproved;
      case 'case_rejected':
        return NotificationType.caseRejected;
      case 'organization_approved':
        return NotificationType.organizationApproved;
      case 'volunteer_request_accepted':
        return NotificationType.volunteerRequestAccepted;
      case 'volunteer_request_rejected':
        return NotificationType.volunteerRequestRejected;
      default:
        return NotificationType.general;
    }
  }
}
