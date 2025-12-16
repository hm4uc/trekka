import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String userId;
  final String? destId;
  final String? eventId;
  final int rating;
  final String comment;
  final String sentiment;
  final List<String> images;
  final int helpfulCount;
  final bool isVerifiedVisit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewUser? user;
  final ReviewDestination? destination;
  final ReviewEventEntity? event;

  const Review({
    required this.id,
    required this.userId,
    this.destId,
    this.eventId,
    required this.rating,
    required this.comment,
    required this.sentiment,
    required this.images,
    required this.helpfulCount,
    required this.isVerifiedVisit,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.destination,
    this.event,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        destId,
        eventId,
        rating,
        comment,
        sentiment,
        images,
        helpfulCount,
        isVerifiedVisit,
        isActive,
        createdAt,
        updatedAt,
        user,
        destination,
        event,
      ];
}

class ReviewUser extends Equatable {
  final String id;
  final String fullname;
  final String? avatar;

  const ReviewUser({
    required this.id,
    required this.fullname,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, fullname, avatar];
}

class ReviewDestination extends Equatable {
  final String id;
  final String name;
  final List<String> images;

  const ReviewDestination({
    required this.id,
    required this.name,
    required this.images,
  });

  @override
  List<Object?> get props => [id, name, images];
}

class ReviewEventEntity extends Equatable {
  final String id;
  final String name;
  final List<String> images;

  const ReviewEventEntity({
    required this.id,
    required this.name,
    required this.images,
  });

  @override
  List<Object?> get props => [id, name, images];
}

