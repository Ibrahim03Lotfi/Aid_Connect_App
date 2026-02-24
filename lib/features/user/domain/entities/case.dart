import 'package:equatable/equatable.dart';

class Case extends Equatable {
  final int id;
  final String title;
  final String description;
  final String governorate;
  final String category;
  final int categoryId;
  final int governorateId;
  final String status;
  final String priority;
  final String? thumbnail;
  final List<String> images;
  final int views;
  final DateTime createdAt;
  final bool isFavorited;
  final String? organizationName;
  final List<CaseAttachment> attachments;

  const Case({
    required this.id,
    required this.title,
    required this.description,
    required this.governorate,
    required this.category,
    required this.categoryId,
    required this.governorateId,
    required this.status,
    required this.priority,
    this.thumbnail,
    this.images = const [],
    this.views = 0,
    required this.createdAt,
    this.isFavorited = false,
    this.organizationName,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        governorate,
        category,
        categoryId,
        governorateId,
        status,
        priority,
        thumbnail,
        images,
        views,
        createdAt,
        isFavorited,
        organizationName,
        attachments,
      ];
}

class CaseAttachment extends Equatable {
  final int id;
  final String name;
  final String url;
  final String type;
  final int size;

  const CaseAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  @override
  List<Object?> get props => [id, name, url, type, size];
}
