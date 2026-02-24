import 'package:equatable/equatable.dart';

class Governorate extends Equatable {
  final int id;
  final String name;
  final String? code;
  final int casesCount;

  const Governorate({
    required this.id,
    required this.name,
    this.code,
    this.casesCount = 0,
  });

  @override
  List<Object?> get props => [id, name, code, casesCount];
}
