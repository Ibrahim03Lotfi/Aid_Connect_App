import 'package:equatable/equatable.dart';

class OrgCase extends Equatable {
  final int id;
  final String title;
  final String description;
  final String status; // pending, approved, rejected
  final String priority; // urgent, high, medium, low
  final String category;
  final String governorate;
  final int views;
  final int donationsCount;
  final DateTime createdAt;
  final String? thumbnail;
  final String? rejectionReason; // Only when status is rejected
  final List<String> images;

  const OrgCase({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.governorate,
    this.views = 0,
    this.donationsCount = 0,
    required this.createdAt,
    this.thumbnail,
    this.rejectionReason,
    this.images = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        category,
        governorate,
        views,
        donationsCount,
        createdAt,
        thumbnail,
        rejectionReason,
        images,
      ];

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
