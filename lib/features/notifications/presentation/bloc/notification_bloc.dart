import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  int _currentPage = 1;
  static const int _limit = 20;

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<LoadMoreNotificationsEvent>(_onLoadMoreNotifications);
    on<ShowLocalNotificationEvent>(_onShowLocalNotification);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.refresh) {
      _currentPage = 1;
      emit(const NotificationLoading());
    } else if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(NotificationLoading(currentNotifications: currentState.notifications));
    } else {
      emit(const NotificationLoading());
    }

    final result = await _repository.getNotifications(
      page: _currentPage,
      limit: _limit,
    );

    final statsResult = await _repository.getNotificationStats();

    result.fold(
      (failure) => emit(NotificationError(
        _mapFailureToMessage(failure),
        previousNotifications: state is NotificationsLoaded
            ? (state as NotificationsLoaded).notifications
            : null,
      )),
      (notifications) {
        final unreadCount = statsResult.fold(
          (failure) => 0,
          (stats) => stats.unread,
        );

        emit(NotificationsLoaded(
          notifications: notifications,
          hasReachedMax: notifications.length < _limit,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    // Optimistically update UI
    final updatedNotifications = currentState.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      hasReachedMax: currentState.hasReachedMax,
      unreadCount: currentState.unreadCount > 0
          ? currentState.unreadCount - 1
          : 0,
    ));

    // Call repository
    final result = await _repository.markAsRead(event.notificationId);

    result.fold(
      (failure) {
        // Revert on failure
        emit(NotificationError(
          _mapFailureToMessage(failure),
          previousNotifications: currentState.notifications,
        ));
      },
      (_) {
        emit(MarkAsReadSuccess(
          notifications: updatedNotifications,
          notificationId: event.notificationId,
          hasReachedMax: currentState.hasReachedMax,
          unreadCount: currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : 0,
        ));
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    // Optimistically update UI
    final updatedNotifications = currentState.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      hasReachedMax: currentState.hasReachedMax,
      unreadCount: 0,
    ));

    // Call repository
    final result = await _repository.markAllAsRead();

    result.fold(
      (failure) {
        emit(NotificationError(
          _mapFailureToMessage(failure),
          previousNotifications: currentState.notifications,
        ));
      },
      (_) {
        emit(MarkAllAsReadSuccess(
          notifications: updatedNotifications,
          hasReachedMax: currentState.hasReachedMax,
          unreadCount: 0,
        ));
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    // Optimistically update UI
    final updatedNotifications = currentState.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    final wasUnread = currentState.notifications
        .firstWhere((n) => n.id == event.notificationId)
        .isRead == false;

    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      hasReachedMax: currentState.hasReachedMax,
      unreadCount: wasUnread && currentState.unreadCount > 0
          ? currentState.unreadCount - 1
          : currentState.unreadCount,
    ));

    // Call repository
    final result = await _repository.deleteNotification(event.notificationId);

    result.fold(
      (failure) {
        emit(NotificationError(
          _mapFailureToMessage(failure),
          previousNotifications: currentState.notifications,
        ));
      },
      (_) {
        emit(DeleteNotificationSuccess(
          notifications: updatedNotifications,
          deletedNotificationId: event.notificationId,
          hasReachedMax: currentState.hasReachedMax,
          unreadCount: wasUnread && currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : currentState.unreadCount,
        ));
      },
    );
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final currentState = state as NotificationsLoaded;

    if (currentState.hasReachedMax) return;

    emit(NotificationsLoadingMore(
      notifications: currentState.notifications,
      hasReachedMax: currentState.hasReachedMax,
      unreadCount: currentState.unreadCount,
    ));

    _currentPage++;

    final result = await _repository.getNotifications(
      page: _currentPage,
      limit: _limit,
    );

    result.fold(
      (failure) {
        _currentPage--;
        emit(NotificationError(
          _mapFailureToMessage(failure),
          previousNotifications: currentState.notifications,
        ));
      },
      (newNotifications) {
        final allNotifications = [...currentState.notifications, ...newNotifications];
        emit(NotificationsLoaded(
          notifications: allNotifications,
          hasReachedMax: newNotifications.length < _limit,
          unreadCount: currentState.unreadCount,
        ));
      },
    );
  }

  Future<void> _onShowLocalNotification(
    ShowLocalNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final currentState = state as NotificationsLoaded;

    final result = await _repository.showLocalNotification(
      title: event.title,
      body: event.body,
      type: NotificationType.general,
    );

    result.fold(
      (failure) => emit(NotificationError(
        _mapFailureToMessage(failure),
        previousNotifications: currentState.notifications,
      )),
      (_) => emit(LocalNotificationShown(
        notifications: currentState.notifications,
        hasReachedMax: currentState.hasReachedMax,
        unreadCount: currentState.unreadCount,
      )),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (failure is CacheFailure) {
      return 'فشل في الوصول للبيانات المحلية';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
}
