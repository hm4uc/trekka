import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, Review>> createReview({
    String? destId,
    String? eventId,
    required int rating,
    required String comment,
    List<String>? images,
  });

  Future<Either<Failure, Map<String, dynamic>>> getDestinationReviews({
    required String destId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  });

  Future<Either<Failure, Map<String, dynamic>>> getEventReviews({
    required String eventId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Map<String, dynamic>>> getMyReviews({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Review>> updateReview({
    required String id,
    int? rating,
    String? comment,
    List<String>? images,
  });

  Future<Either<Failure, void>> deleteReview(String id);

  Future<Either<Failure, Map<String, dynamic>>> markReviewHelpful(String id);
}

