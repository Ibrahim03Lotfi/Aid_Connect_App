import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch notifications event
class FetchNotificationsEvent extends NotificationEvent {
  final int page;
  final bool refresh;

  const FetchNotificationsEvent({
    this.page = 1,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, refresh];
}

/// Mark notification as read event
class MarkAsReadEvent extends NotificationEvent {
  final int notificationId;

  const MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read event
class MarkAllAsReadEvent extends NotificationEvent {
  const MarkAllAsReadEvent();
}

/// Delete notification event
class DeleteNotificationEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Load more notifications event (pagination)
class LoadMoreNotificationsEvent extends NotificationEvent {
  const LoadMoreNotificationsEvent();
}

/// Show local notification event
class ShowLocalNotificationEvent extends NotificationEvent {
  final String title;
  final String body;

  const ShowLocalNotificationEvent({
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [title, body];
}
