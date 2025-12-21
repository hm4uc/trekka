import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class GetDestinationReviewsEvent extends ReviewEvent {
  final String destId;
  final int page;
  final int limit;
  final String sortBy;

  const GetDestinationReviewsEvent({
    required this.destId,
    this.page = 1,
    this.limit = 10,
    this.sortBy = 'recent',
  });

  @override
  List<Object?> get props => [destId, page, limit, sortBy];
}

class GetEventReviewsEvent extends ReviewEvent {
  final String eventId;
  final int page;
  final int limit;

  const GetEventReviewsEvent({
    required this.eventId,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [eventId, page, limit];
}

class GetMyReviewsEvent extends ReviewEvent {
  final int page;
  final int limit;

  const GetMyReviewsEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

class CreateReviewEvent extends ReviewEvent {
  final String? destId;
  final String? eventId;
  final int rating;
  final String comment;
  final List<String>? images;

  const CreateReviewEvent({
    this.destId,
    this.eventId,
    required this.rating,
    required this.comment,
    this.images,
  });

  @override
  List<Object?> get props => [destId, eventId, rating, comment, images];
}

class UpdateReviewEvent extends ReviewEvent {
  final String id;
  final int? rating;
  final String? comment;
  final List<String>? images;

  const UpdateReviewEvent({
    required this.id,
    this.rating,
    this.comment,
    this.images,
  });

  @override
  List<Object?> get props => [id, rating, comment, images];
}

class DeleteReviewEvent extends ReviewEvent {
  final String id;

  const DeleteReviewEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkReviewHelpfulEvent extends ReviewEvent {
  final String id;

  const MarkReviewHelpfulEvent(this.id);

  @override
  List<Object?> get props => [id];
}

