import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/destination_repository.dart';

class GetCheckedInItems {
  final DestinationRepository repository;

  GetCheckedInItems(this.repository);

  Future<Either<Failure, UserActivityResult>> call({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    return await repository.getCheckedInItems(
      page: page,
      limit: limit,
      type: type,
    );
  }
}

