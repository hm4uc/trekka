import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class GetDestinationReviews implements UseCase<Map<String, dynamic>, GetDestinationReviewsParams> {
  final ReviewRepository repository;

  GetDestinationReviews(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetDestinationReviewsParams params) async {
    return await repository.getDestinationReviews(
      destId: params.destId,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
    );
  }
}

class GetDestinationReviewsParams {
  final String destId;
  final int page;
  final int limit;
  final String sortBy;

  GetDestinationReviewsParams({
    required this.destId,
    this.page = 1,
    this.limit = 10,
    this.sortBy = 'recent',
  });
}
