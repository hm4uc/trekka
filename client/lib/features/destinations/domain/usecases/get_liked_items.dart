import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/destination_repository.dart';

class GetLikedItems {
  final DestinationRepository repository;

  GetLikedItems(this.repository);

  Future<Either<Failure, UserActivityResult>> call({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    return await repository.getLikedItems(
      page: page,
      limit: limit,
      type: type,
    );
  }
}

