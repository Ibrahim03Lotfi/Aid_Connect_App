import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? icon;
  final int casesCount;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.casesCount = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, casesCount];
}
