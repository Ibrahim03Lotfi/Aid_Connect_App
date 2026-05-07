import 'package:equatable/equatable.dart';

abstract class OrgProfileEvent extends Equatable {
  const OrgProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends OrgProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends OrgProfileEvent {
  final String? name;
  final String? phone;
  final String? address;
  final String? description;
  final String? registrationNumber;

  const UpdateProfile({
    this.name,
    this.phone,
    this.address,
    this.description,
    this.registrationNumber,
  });

  @override
  List<Object?> get props => [name, phone, address, description, registrationNumber];
}
