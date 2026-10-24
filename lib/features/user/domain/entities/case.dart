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
  final int likesCount;
  final int commentsCount;
  final double targetAmount;
  final double collectedAmount;
  final int progressPercent;
  final int? aiUrgencyIndex;
  final String? aiTriageTier;
  final List<String>? aiVulnerabilityFactors;
  final String? aiFraudStatus;

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
    this.likesCount = 48,
    this.commentsCount = 6,
    this.targetAmount = 2500000.0,
    this.collectedAmount = 1850000.0,
    this.progressPercent = 74,
    this.aiUrgencyIndex,
    this.aiTriageTier,
    this.aiVulnerabilityFactors,
    this.aiFraudStatus,
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
        likesCount,
        commentsCount,
        targetAmount,
        collectedAmount,
        progressPercent,
        aiUrgencyIndex,
        aiTriageTier,
        aiVulnerabilityFactors,
        aiFraudStatus,
      ];

  Case copyWith({
    int? id,
    String? title,
    String? description,
    String? governorate,
    String? category,
    int? categoryId,
    int? governorateId,
    String? status,
    String? priority,
    String? thumbnail,
    List<String>? images,
    int? views,
    DateTime? createdAt,
    bool? isFavorited,
    String? organizationName,
    List<CaseAttachment>? attachments,
    int? likesCount,
    int? commentsCount,
    double? targetAmount,
    double? collectedAmount,
    int? progressPercent,
    int? aiUrgencyIndex,
    String? aiTriageTier,
    List<String>? aiVulnerabilityFactors,
    String? aiFraudStatus,
  }) {
    return Case(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      governorate: governorate ?? this.governorate,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      governorateId: governorateId ?? this.governorateId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isFavorited: isFavorited ?? this.isFavorited,
      organizationName: organizationName ?? this.organizationName,
      attachments: attachments ?? this.attachments,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      targetAmount: targetAmount ?? this.targetAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      progressPercent: progressPercent ?? this.progressPercent,
      aiUrgencyIndex: aiUrgencyIndex ?? this.aiUrgencyIndex,
      aiTriageTier: aiTriageTier ?? this.aiTriageTier,
      aiVulnerabilityFactors: aiVulnerabilityFactors ?? this.aiVulnerabilityFactors,
      aiFraudStatus: aiFraudStatus ?? this.aiFraudStatus,
    );
  }
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
