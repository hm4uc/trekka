import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    super.destId,
    super.eventId,
    required super.rating,
    required super.comment,
    required super.sentiment,
    required super.images,
    required super.helpfulCount,
    required super.isVerifiedVisit,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.user,
    super.destination,
    super.event,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      destId: json['dest_id'] as String?,
      eventId: json['event_id'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      sentiment: json['sentiment'] as String? ?? 'neutral',
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      helpfulCount: json['helpful_count'] as int? ?? 0,
      isVerifiedVisit: json['is_verified_visit'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: json['user'] != null ? ReviewUserModel.fromJson(json['user']) : null,
      destination: json['destination'] != null ? ReviewDestinationModel.fromJson(json['destination']) : null,
      event: json['event'] != null ? ReviewEventModel.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'dest_id': destId,
      'event_id': eventId,
      'rating': rating,
      'comment': comment,
      'sentiment': sentiment,
      'images': images,
      'helpful_count': helpfulCount,
      'is_verified_visit': isVerifiedVisit,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ReviewUserModel extends ReviewUser {
  const ReviewUserModel({
    required super.id,
    required super.fullname,
    super.avatar,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: json['id'] as String,
      fullname: json['usr_fullname'] as String,
      avatar: json['usr_avatar'] as String?,
    );
  }
}

class ReviewDestinationModel extends ReviewDestination {
  const ReviewDestinationModel({
    required super.id,
    required super.name,
    required super.images,
  });

  factory ReviewDestinationModel.fromJson(Map<String, dynamic> json) {
    return ReviewDestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class ReviewEventModel extends ReviewEventEntity {
  const ReviewEventModel({
    required super.id,
    required super.name,
    required super.images,
  });

  factory ReviewEventModel.fromJson(Map<String, dynamic> json) {
    return ReviewEventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

