import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../services/local_storage_service.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Mock implementation of NotificationRepository for Phase 6
/// This is a static implementation for demonstration purposes
class NotificationRepositoryImpl implements NotificationRepository {
  final LocalStorageService _localStorage;

  // Mock notifications data
  final List<Notification> _mockNotifications = [
    Notification(
      id: 1,
      title: 'تم قبول حالتك',
      body: 'تمت الموافقة على حالة "مساعدة عاجلة لعائلة متضررة" بنجاح.',
      type: NotificationType.caseApproved,
      createdAt: DateTime(2026, 2, 28, 10, 30),
      isRead: false,
      relatedCaseId: 101,
      relatedEntityName: 'مساعدة عاجلة لعائلة متضررة',
    ),
    Notification(
      id: 2,
      title: 'حالة مرفوضة',
      body: 'تم رفض حالتك "طلب دواء طارئ".',
      type: NotificationType.caseRejected,
      createdAt: DateTime(2026, 2, 27, 15, 45),
      isRead: false,
      relatedCaseId: 102,
      relatedEntityName: 'طلب دواء طارئ',
      rejectionReason: 'الوصف غير واضح، يرجى تقديم المزيد من التفاصيل والمستندات الطبية',
    ),
    Notification(
      id: 3,
      title: 'تمت الموافقة على المنظمة',
      body: 'تمت الموافقة على طلب انضمام منظمتك "جمعية الخير" بنجاح.',
      type: NotificationType.organizationApproved,
      createdAt: DateTime(2026, 2, 26, 9, 0),
      isRead: true,
      relatedEntityName: 'جمعية الخير',
    ),
    Notification(
      id: 4,
      title: 'تم قبول طلب التطوع',
      body: 'تم قبول طلبك للتطوع في حالة "توزيع سلال غذائية".',
      type: NotificationType.volunteerRequestAccepted,
      createdAt: DateTime(2026, 2, 25, 14, 20),
      isRead: true,
      relatedCaseId: 103,
      relatedEntityName: 'توزيع سلال غذائية',
    ),
    Notification(
      id: 5,
      title: 'طلب تطوع مرفوض',
      body: 'تم رفض طلبك للتطوع في حالة "إفطار صائم".',
      type: NotificationType.volunteerRequestRejected,
      createdAt: DateTime(2026, 2, 24, 11, 10),
      isRead: true,
      relatedCaseId: 104,
      relatedEntityName: 'إفطار صائم',
      rejectionReason: 'اكتمال العدد المطلوب من المتطوعين',
    ),
    Notification(
      id: 6,
      title: 'إشعار عام',
      body: 'تم تحديث سياسات الخصوصية. يرجى مراجعة الشروط والأحكام.',
      type: NotificationType.general,
      createdAt: DateTime(2026, 2, 23, 8, 0),
      isRead: true,
    ),
  ];

  NotificationRepositoryImpl(this._localStorage);

  @override
  Future<Either<Failure, List<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Calculate pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= _mockNotifications.length) {
        return const Right([]);
      }

      final paginatedNotifications = _mockNotifications.sublist(
        startIndex,
        endIndex > _mockNotifications.length
            ? _mockNotifications.length
            : endIndex,
      );

      return Right(paginatedNotifications);
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, NotificationStats>> getNotificationStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final unreadCount =
          _mockNotifications.where((n) => !n.isRead).length;

      return Right(NotificationStats(
        total: _mockNotifications.length,
        unread: unreadCount,
      ));
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل إحصائيات الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _mockNotifications[index] =
            _mockNotifications[index].copyWith(isRead: true);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث حالة الإشعار'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      for (var i = 0; i < _mockNotifications.length; i++) {
        if (!_mockNotifications[i].isRead) {
          _mockNotifications[i] =
              _mockNotifications[i].copyWith(isRead: true);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث حالة الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _mockNotifications.removeWhere((n) => n.id == notificationId);

      return const Right(null);
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
    try {
      // Simulate showing a local notification
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل في عرض الإشعار'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    required DateTime scheduledTime,
  }) async {
    try {
      // Simulate scheduling a notification
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل في جدولة الإشعار'));
    }
  }
}
