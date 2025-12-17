import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class UpdateReview implements UseCase<Review, UpdateReviewParams> {
  final ReviewRepository repository;

  UpdateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(UpdateReviewParams params) async {
    return await repository.updateReview(
      id: params.id,
      rating: params.rating,
      comment: params.comment,
      images: params.images,
    );
  }
}

class UpdateReviewParams {
  final String id;
  final int? rating;
  final String? comment;
  final List<String>? images;

  UpdateReviewParams({
    required this.id,
    this.rating,
    this.comment,
    this.images,
  });
}

