import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  final List<Notification>? currentNotifications;

  const NotificationLoading({this.currentNotifications});

  @override
  List<Object?> get props => [currentNotifications];
}

/// Notifications loaded state
class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  final bool hasReachedMax;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.hasReachedMax = false,
    this.unreadCount = 0,
  });

  NotificationsLoaded copyWith({
    List<Notification>? notifications,
    bool? hasReachedMax,
    int? unreadCount,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, hasReachedMax, unreadCount];
}

/// Loading more state (pagination)
class NotificationsLoadingMore extends NotificationsLoaded {
  const NotificationsLoadingMore({
    required super.notifications,
    super.hasReachedMax,
    super.unreadCount,
  });
}

/// Error state
class NotificationError extends NotificationState {
  final String message;
  final List<Notification>? previousNotifications;

  const NotificationError(
    this.message, {
    this.previousNotifications,
  });

  @override
  List<Object?> get props => [message, previousNotifications];
}

/// Mark as read success state
class MarkAsReadSuccess extends NotificationsLoaded {
  final int notificationId;

  const MarkAsReadSuccess({
    required super.notifications,
    required this.notificationId,
    super.hasReachedMax,
    super.unreadCount,
  });

  @override
  List<Object?> get props => [...super.props, notificationId];
}

/// Mark all as read success state
class MarkAllAsReadSuccess extends NotificationsLoaded {
  const MarkAllAsReadSuccess({
    required super.notifications,
    super.hasReachedMax,
    super.unreadCount,
  });
}

/// Delete notification success state
class DeleteNotificationSuccess extends NotificationsLoaded {
  final int deletedNotificationId;

  const DeleteNotificationSuccess({
    required super.notifications,
    required this.deletedNotificationId,
    super.hasReachedMax,
    super.unreadCount,
  });

  @override
  List<Object?> get props => [...super.props, deletedNotificationId];
}

/// Local notification shown state
class LocalNotificationShown extends NotificationsLoaded {
  const LocalNotificationShown({
    required super.notifications,
    super.hasReachedMax,
    super.unreadCount,
  });
}
