import 'package:equatable/equatable.dart';

class BeneficiaryEntity extends Equatable {
  final int id;
  final String headOfFamilyName;
  final String nationalId;
  final String? phone;
  final int familyMembersCount;
  final String? governorate;
  final String? address;
  final String? nfcCardUid;
  final String? qrToken;
  final int vulnerabilityScore;
  final String status;
  final String? itemAllocated;

  const BeneficiaryEntity({
    required this.id,
    required this.headOfFamilyName,
    required this.nationalId,
    this.phone,
    required this.familyMembersCount,
    this.governorate,
    this.address,
    this.nfcCardUid,
    this.qrToken,
    this.vulnerabilityScore = 75,
    this.status = 'active',
    this.itemAllocated,
  });

  factory BeneficiaryEntity.fromJson(Map<String, dynamic> json) {
    return BeneficiaryEntity(
      id: json['id'] as int? ?? 0,
      headOfFamilyName: json['head_of_family_name'] as String? ?? 'عائلة مستفيدة',
      nationalId: json['national_id'] as String? ?? '',
      phone: json['phone'] as String?,
      familyMembersCount: json['family_members_count'] as int? ?? 1,
      governorate: json['governorate']?['name'] as String? ?? json['governorate_name'] as String? ?? 'دمشق',
      address: json['address'] as String?,
      nfcCardUid: json['nfc_card_uid'] as String?,
      qrToken: json['qr_token'] as String?,
      vulnerabilityScore: json['vulnerability_score'] as int? ?? 75,
      status: json['status'] as String? ?? 'active',
      itemAllocated: json['item_allocated'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, nationalId, nfcCardUid, qrToken];
}

class AidCampaignEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String itemType;
  final int itemsAllocatedPerFamily;
  final int targetFamiliesCount;
  final int distributedFamiliesCount;
  final String status;

  const AidCampaignEntity({
    required this.id,
    required this.title,
    this.description,
    this.itemType = 'سلة إغاثية',
    this.itemsAllocatedPerFamily = 1,
    this.targetFamiliesCount = 100,
    this.distributedFamiliesCount = 0,
    this.status = 'active',
  });

  factory AidCampaignEntity.fromJson(Map<String, dynamic> json) {
    return AidCampaignEntity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'حملة إغاثية',
      description: json['description'] as String?,
      itemType: json['item_type'] as String? ?? 'سلة إغاثية متكاملة',
      itemsAllocatedPerFamily: json['items_allocated_per_family'] as int? ?? 1,
      targetFamiliesCount: json['target_families_count'] as int? ?? 100,
      distributedFamiliesCount: json['distributed_families_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
    );
  }

  @override
  List<Object?> get props => [id, title, status];
}

class EmergencyMissionEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String urgency;
  final List<String> requiredSkills;
  final int volunteersNeeded;
  final int volunteersJoined;
  final String status;
  final String? location;
  final bool isJoined;
  final bool isCheckedIn;

  const EmergencyMissionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.urgency,
    this.requiredSkills = const [],
    required this.volunteersNeeded,
    required this.volunteersJoined,
    required this.status,
    this.location,
    this.isJoined = false,
    this.isCheckedIn = false,
  });

  factory EmergencyMissionEntity.fromJson(Map<String, dynamic> json) {
    return EmergencyMissionEntity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'مهمة استجابة طارئة',
      description: json['description'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'urgent',
      requiredSkills: (json['required_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      volunteersNeeded: json['volunteers_needed'] as int? ?? 5,
      volunteersJoined: json['volunteers_joined'] as int? ?? 0,
      status: json['status'] as String? ?? 'open',
      location: json['location'] as String? ?? json['district'] as String? ?? 'دمشق',
      isJoined: json['is_joined'] as bool? ?? false,
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
    );
  }

  EmergencyMissionEntity copyWith({
    bool? isJoined,
    bool? isCheckedIn,
    int? volunteersJoined,
  }) {
    return EmergencyMissionEntity(
      id: id,
      title: title,
      description: description,
      urgency: urgency,
      requiredSkills: requiredSkills,
      volunteersNeeded: volunteersNeeded,
      volunteersJoined: volunteersJoined ?? this.volunteersJoined,
      status: status,
      location: location,
      isJoined: isJoined ?? this.isJoined,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }

  @override
  List<Object?> get props => [id, title, urgency, isJoined, isCheckedIn];
}

class VolunteerPassportEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int volunteerHours;
  final int volunteerPoints;
  final int familiesHelped;
  final List<String> badges;
  final String certificateUrl;
  final String joinDate;

  const VolunteerPassportEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.volunteerHours,
    required this.volunteerPoints,
    required this.familiesHelped,
    this.badges = const [],
    required this.certificateUrl,
    required this.joinDate,
  });

  factory VolunteerPassportEntity.fromJson(Map<String, dynamic> json) {
    return VolunteerPassportEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'متطوع أثر',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      volunteerHours: json['volunteer_hours'] as int? ?? 0,
      volunteerPoints: json['volunteer_points'] as int? ?? 0,
      familiesHelped: json['families_helped'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['المستجيب السريع', 'حارس الأمل'],
      certificateUrl: json['certificate_url'] as String? ??
          'https://athar-relief.org/verify/volunteer/${json['id'] ?? 1}',
      joinDate: json['joined_at'] as String? ?? 'يناير 2026',
    );
  }

  @override
  List<Object?> get props => [id, name, volunteerHours, volunteerPoints, familiesHelped];
}
