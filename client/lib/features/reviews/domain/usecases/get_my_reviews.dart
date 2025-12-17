import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class GetMyReviews implements UseCase<Map<String, dynamic>, GetMyReviewsParams> {
  final ReviewRepository repository;

  GetMyReviews(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetMyReviewsParams params) async {
    return await repository.getMyReviews(
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetMyReviewsParams {
  final int page;
  final int limit;

  GetMyReviewsParams({
    this.page = 1,
    this.limit = 10,
  });
}

