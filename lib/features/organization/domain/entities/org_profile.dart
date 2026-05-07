import 'package:equatable/equatable.dart';

class OrgProfile extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String description;
  final String registrationNumber;
  final String joinedAt;

  const OrgProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.registrationNumber,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        address,
        description,
        registrationNumber,
        joinedAt,
      ];
}
