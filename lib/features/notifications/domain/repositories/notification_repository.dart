import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';

/// Repository interface for notifications
abstract class NotificationRepository {
  /// Get all notifications with pagination
  Future<Either<Failure, List<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  /// Get unread notifications count
  Future<Either<Failure, NotificationStats>> getNotificationStats();

  /// Mark a single notification as read
  Future<Either<Failure, void>> markAsRead(int notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(int notificationId);

  /// Show local notification
  Future<Either<Failure, void>> showLocalNotification({
    required String title,
    required String body,
    required NotificationType type,
  });

  /// Schedule notification for later
  Future<Either<Failure, void>> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    required DateTime scheduledTime,
  });
}
