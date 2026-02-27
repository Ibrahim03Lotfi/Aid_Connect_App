import 'package:equatable/equatable.dart';

class VolunteerCase extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final String governorate;
  final String priority;
  final String organizationName;
  final DateTime createdAt;
  final int volunteersNeeded;
  final int volunteersApplied;
  final String? thumbnail;
  final bool isUrgent;

  const VolunteerCase({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.governorate,
    required this.priority,
    required this.organizationName,
    required this.createdAt,
    this.volunteersNeeded = 1,
    this.volunteersApplied = 0,
    this.thumbnail,
    this.isUrgent = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        governorate,
        priority,
        organizationName,
        createdAt,
        volunteersNeeded,
        volunteersApplied,
        thumbnail,
        isUrgent,
      ];

  bool get isFull => volunteersApplied >= volunteersNeeded;
  int get remainingSpots => volunteersNeeded - volunteersApplied;
}

class VolunteerApplication extends Equatable {
  final int id;
  final int caseId;
  final String caseTitle;
  final String status; // pending, accepted, rejected, completed
  final DateTime appliedAt;
  final String? responseMessage;
  final String organizationName;
  final String category;

  const VolunteerApplication({
    required this.id,
    required this.caseId,
    required this.caseTitle,
    required this.status,
    required this.appliedAt,
    this.responseMessage,
    required this.organizationName,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        caseId,
        caseTitle,
        status,
        appliedAt,
        responseMessage,
        organizationName,
        category,
      ];

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';
}
