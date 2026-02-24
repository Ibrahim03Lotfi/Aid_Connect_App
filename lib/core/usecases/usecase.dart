import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaginationParams extends Equatable {
  final int page;
  final int perPage;

  const PaginationParams({this.page = 1, this.perPage = 10});

  @override
  List<Object?> get props => [page, perPage];
}

class IdParams extends Equatable {
  final int id;

  const IdParams(this.id);

  @override
  List<Object?> get props => [id];
}
