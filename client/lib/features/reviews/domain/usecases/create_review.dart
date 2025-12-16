import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class CreateReview implements UseCase<Review, CreateReviewParams> {
  final ReviewRepository repository;

  CreateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(CreateReviewParams params) async {
    return await repository.createReview(
      destId: params.destId,
      eventId: params.eventId,
      rating: params.rating,
      comment: params.comment,
      images: params.images,
    );
  }
}

class CreateReviewParams {
  final String? destId;
  final String? eventId;
  final int rating;
  final String comment;
  final List<String>? images;

  CreateReviewParams({
    this.destId,
    this.eventId,
    required this.rating,
    required this.comment,
    this.images,
  });
}

