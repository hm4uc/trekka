import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Review>> createReview({
    String? destId,
    String? eventId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    try {
      final response = await remoteDataSource.createReview(
        destId: destId,
        eventId: eventId,
        rating: rating,
        comment: comment,
        images: images,
      );
      final review = ReviewModel.fromJson(response['data']);
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDestinationReviews({
    required String destId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  }) async {
    try {
      final response = await remoteDataSource.getDestinationReviews(
        destId: destId,
        page: page,
        limit: limit,
        sortBy: sortBy,
      );

      final data = response['data'] as Map<String, dynamic>;
      final reviewsList = (data['data'] as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      return Right({
        'total': data['total'],
        'currentPage': data['currentPage'],
        'totalPages': data['totalPages'],
        'reviews': reviewsList,
      });
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEventReviews({
    required String eventId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await remoteDataSource.getEventReviews(
        eventId: eventId,
        page: page,
        limit: limit,
      );

      final data = response['data'] as Map<String, dynamic>;
      final reviewsList = (data['data'] as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      return Right({
        'total': data['total'],
        'currentPage': data['currentPage'],
        'totalPages': data['totalPages'],
        'reviews': reviewsList,
      });
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMyReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await remoteDataSource.getMyReviews(
        page: page,
        limit: limit,
      );

      final data = response['data'] as Map<String, dynamic>;
      final reviewsList = (data['data'] as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      return Right({
        'total': data['total'],
        'currentPage': data['currentPage'],
        'totalPages': data['totalPages'],
        'reviews': reviewsList,
      });
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required String id,
    int? rating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final review = await remoteDataSource.updateReview(
        id: id,
        rating: rating,
        comment: comment,
        images: images,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String id) async {
    try {
      await remoteDataSource.deleteReview(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> markReviewHelpful(String id) async {
    try {
      final response = await remoteDataSource.markReviewHelpful(id);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }
}

