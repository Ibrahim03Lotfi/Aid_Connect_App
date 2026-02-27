import 'package:equatable/equatable.dart';

/// Notification types for different events
enum NotificationType {
  caseApproved,
  caseRejected,
  organizationApproved,
  volunteerRequestAccepted,
  volunteerRequestRejected,
  general,
}

/// Notification entity representing a user notification
class Notification extends Equatable {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final int? relatedCaseId;
  final String? relatedEntityName;
  final String? rejectionReason;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedCaseId,
    this.relatedEntityName,
    this.rejectionReason,
  });

  Notification copyWith({
    int? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    int? relatedCaseId,
    String? relatedEntityName,
    String? rejectionReason,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedCaseId: relatedCaseId ?? this.relatedCaseId,
      relatedEntityName: relatedEntityName ?? this.relatedEntityName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        createdAt,
        isRead,
        relatedCaseId,
        relatedEntityName,
        rejectionReason,
      ];
}

/// Notification statistics
class NotificationStats extends Equatable {
  final int total;
  final int unread;

  const NotificationStats({
    required this.total,
    required this.unread,
  });

  @override
  List<Object?> get props => [total, unread];
}
