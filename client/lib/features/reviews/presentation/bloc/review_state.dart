import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart' as entities;

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<entities.Review> reviews;
  final int total;
  final int currentPage;
  final int totalPages;

  const ReviewsLoaded({
    required this.reviews,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [reviews, total, currentPage, totalPages];
}

class ReviewCreated extends ReviewState {
  final entities.Review review;

  const ReviewCreated(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewUpdated extends ReviewState {
  final entities.Review review;

  const ReviewUpdated(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewDeleted extends ReviewState {}

class ReviewMarkedHelpful extends ReviewState {
  final String reviewId;
  final bool isHelpful;
  final int helpfulCount;

  const ReviewMarkedHelpful({
    required this.reviewId,
    required this.isHelpful,
    required this.helpfulCount,
  });

  @override
  List<Object?> get props => [reviewId, isHelpful, helpfulCount];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

