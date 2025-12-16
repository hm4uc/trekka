import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/delete_review.dart';
import '../../domain/usecases/get_destination_reviews.dart';
import '../../domain/usecases/get_my_reviews.dart';
import '../../domain/usecases/mark_review_helpful.dart';
import '../../domain/usecases/update_review.dart';
import 'review_event.dart' as events;
import 'review_state.dart';

class ReviewBloc extends Bloc<events.ReviewEvent, ReviewState> {
  final GetDestinationReviews getDestinationReviews;
  final GetMyReviews getMyReviews;
  final CreateReview createReview;
  final UpdateReview updateReview;
  final DeleteReview deleteReview;
  final MarkReviewHelpful markReviewHelpful;

  ReviewBloc({
    required this.getDestinationReviews,
    required this.getMyReviews,
    required this.createReview,
    required this.updateReview,
    required this.deleteReview,
    required this.markReviewHelpful,
  }) : super(ReviewInitial()) {
    on<events.GetDestinationReviewsEvent>(_onGetDestinationReviews);
    on<events.GetMyReviewsEvent>(_onGetMyReviews);
    on<events.CreateReviewEvent>(_onCreateReview);
    on<events.UpdateReviewEvent>(_onUpdateReview);
    on<events.DeleteReviewEvent>(_onDeleteReview);
    on<events.MarkReviewHelpfulEvent>(_onMarkReviewHelpful);
  }

  Future<void> _onGetDestinationReviews(
    events.GetDestinationReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await getDestinationReviews(
      GetDestinationReviewsParams(
        destId: event.destId,
        page: event.page,
        limit: event.limit,
        sortBy: event.sortBy,
      ),
    );

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (data) {
        final reviews = data['reviews'] as List;
        emit(ReviewsLoaded(
          reviews: reviews.cast(),
          total: data['total'] as int,
          currentPage: data['currentPage'] as int,
          totalPages: data['totalPages'] as int,
        ));
      },
    );
  }

  Future<void> _onGetMyReviews(
    events.GetMyReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await getMyReviews(
      GetMyReviewsParams(
        page: event.page,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (data) {
        final reviews = data['reviews'] as List;
        emit(ReviewsLoaded(
          reviews: reviews.cast(),
          total: data['total'] as int,
          currentPage: data['currentPage'] as int,
          totalPages: data['totalPages'] as int,
        ));
      },
    );
  }

  Future<void> _onCreateReview(
    events.CreateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await createReview(
      CreateReviewParams(
        destId: event.destId,
        eventId: event.eventId,
        rating: event.rating,
        comment: event.comment,
        images: event.images,
      ),
    );

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewCreated(review)),
    );
  }

  Future<void> _onUpdateReview(
    events.UpdateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await updateReview(
      UpdateReviewParams(
        id: event.id,
        rating: event.rating,
        comment: event.comment,
        images: event.images,
      ),
    );

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewUpdated(review)),
    );
  }

  Future<void> _onDeleteReview(
    events.DeleteReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await deleteReview(event.id);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (_) => emit(ReviewDeleted()),
    );
  }

  Future<void> _onMarkReviewHelpful(
    events.MarkReviewHelpfulEvent event,
    Emitter<ReviewState> emit,
  ) async {
    final result = await markReviewHelpful(event.id);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (data) => emit(ReviewMarkedHelpful(data['data']['helpful_count'] as int)),
    );
  }
}

