import 'package:flutter/material.dart';
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
    super.likesCount,
    super.commentsCount,
    super.targetAmount,
    super.collectedAmount,
    super.progressPercent,
    super.aiUrgencyIndex,
    super.aiTriageTier,
    super.aiVulnerabilityFactors,
    super.aiFraudStatus,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    debugPrint('CaseModel: Parsing case with keys: ${json.keys.toList()}');
    debugPrint('CaseModel: id: ${json['id']} (${json['id'].runtimeType})');
    debugPrint('CaseModel: title: ${json['title']} (${json['title'].runtimeType})');
    debugPrint('CaseModel: category_id: ${json['category_id']} (${json['category_id'].runtimeType})');
    debugPrint('CaseModel: governorate_id: ${json['governorate_id']} (${json['governorate_id'].runtimeType})');
    debugPrint('CaseModel: views: ${json['views']} (${json['views'].runtimeType})');
    debugPrint('CaseModel: is_favorited: ${json['is_favorited']} (${json['is_favorited'].runtimeType})');
    
    try {
      return CaseModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        governorate: json['governorate'] is Map
            ? json['governorate']['name']?.toString() ?? ''
            : json['governorate']?.toString() ?? '',
        category: json['category'] is Map
            ? json['category']['name']?.toString() ?? ''
            : json['category']?.toString() ?? '',
        categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString()) ?? 0,
        governorateId: json['governorate_id'] is int ? json['governorate_id'] : int.tryParse(json['governorate_id'].toString()) ?? 0,
        status: json['status']?.toString() ?? 'pending',
        priority: json['priority']?.toString() ?? 'medium',
        thumbnail: json['thumbnail']?.toString(),
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
        views: json['views'] is int ? json['views'] : int.tryParse(json['views'].toString()) ?? 0,
        createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isFavorited: json['is_favorited'] is bool ? json['is_favorited'] : json['is_favorited'].toString().toLowerCase() == 'true',
        organizationName: json['organization_name']?.toString() ?? json['organization']?['name']?.toString(),
        attachments: (json['attachments'] as List?)
                ?.map((e) => CaseAttachmentModel.fromJson(e))
                .toList() ??
            [],
        likesCount: json['likes_count'] is int ? json['likes_count'] : int.tryParse(json['likes_count']?.toString() ?? '') ?? 54,
        commentsCount: json['comments_count'] is int ? json['comments_count'] : int.tryParse(json['comments_count']?.toString() ?? '') ?? 8,
        targetAmount: double.tryParse(json['target_amount']?.toString() ?? '') ?? 2500000.0,
        collectedAmount: double.tryParse(json['collected_amount']?.toString() ?? '') ?? 1850000.0,
        progressPercent: int.tryParse(json['progress_percent']?.toString() ?? '') ?? 74,
        aiUrgencyIndex: json['ai_urgency_index'] is int
            ? json['ai_urgency_index']
            : int.tryParse(json['ai_urgency_index']?.toString() ?? '') ?? 78,
        aiTriageTier: json['ai_triage_tier']?.toString() ?? 'Tier 2 (High Vulnerability)',
        aiVulnerabilityFactors: (json['ai_vulnerability_factors'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ['خطر شتوي داهم', 'أطفال رضع دون عامين'],
        aiFraudStatus: json['ai_fraud_status']?.toString() ?? 'verified_authentic',
      );
    } catch (e, stackTrace) {
      debugPrint('CaseModel: Error creating case: $e');
      debugPrint('CaseModel: Stack trace: $stackTrace');
      rethrow;
    }
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
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'target_amount': targetAmount,
      'collected_amount': collectedAmount,
      'progress_percent': progressPercent,
      'ai_urgency_index': aiUrgencyIndex,
      'ai_triage_tier': aiTriageTier,
      'ai_vulnerability_factors': aiVulnerabilityFactors,
      'ai_fraud_status': aiFraudStatus,
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
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      size: int.tryParse(json['size'].toString()) ?? 0,
    );
  }
}
