import '../../domain/entities/case.dart';

class CaseModel extends Case {
  const CaseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.governorate,
    required super.category,
    required super.categoryId,
    required super.governorateId,
    required super.status,
    required super.priority,
    super.thumbnail,
    super.images,
    super.views,
    required super.createdAt,
    super.isFavorited,
    super.organizationName,
    super.attachments,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      governorate: json['governorate']?['name'] ?? json['governorate'] ?? '',
      category: json['category']?['name'] ?? json['category'] ?? '',
      categoryId: json['category_id'] ?? 0,
      governorateId: json['governorate_id'] ?? 0,
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      thumbnail: json['thumbnail'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      views: json['views'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isFavorited: json['is_favorited'] ?? false,
      organizationName: json['organization']?['name'],
      attachments: (json['attachments'] as List?)
              ?.map((e) => CaseAttachmentModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'governorate': governorate,
      'category': category,
      'category_id': categoryId,
      'governorate_id': governorateId,
      'status': status,
      'priority': priority,
      'thumbnail': thumbnail,
      'images': images,
      'views': views,
      'created_at': createdAt.toIso8601String(),
      'is_favorited': isFavorited,
      'organization_name': organizationName,
    };
  }
}

class CaseAttachmentModel extends CaseAttachment {
  const CaseAttachmentModel({
    required super.id,
    required super.name,
    required super.url,
    required super.type,
    required super.size,
  });

  factory CaseAttachmentModel.fromJson(Map<String, dynamic> json) {
    return CaseAttachmentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}
