import '../../domain/entities/governorate.dart';

class GovernorateModel extends Governorate {
  const GovernorateModel({
    required super.id,
    required super.name,
    super.code,
    super.casesCount,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      casesCount: json['cases_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'cases_count': casesCount,
    };
  }
}
