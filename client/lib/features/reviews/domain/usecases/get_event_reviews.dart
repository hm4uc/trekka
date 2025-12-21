import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class GetEventReviews implements UseCase<Map<String, dynamic>, GetEventReviewsParams> {
  final ReviewRepository repository;

  GetEventReviews(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetEventReviewsParams params) async {
    return await repository.getEventReviews(
      eventId: params.eventId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetEventReviewsParams {
  final String eventId;
  final int page;
  final int limit;

  GetEventReviewsParams({
    required this.eventId,
    this.page = 1,
    this.limit = 10,
  });
}

