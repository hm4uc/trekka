import '../../domain/entities/destination.dart';

class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.description,
    required super.address,
    required super.lat,
    required super.lng,
    super.avgCost,
    required super.rating,
    required super.totalReviews,
    required super.totalLikes,
    required super.totalSaves,
    required super.totalCheckins,
    required super.tags,
    super.openingHours,
    required super.images,
    super.aiSummary,
    super.bestTimeToVisit,
    super.recommendedDuration,
    required super.isHiddenGem,
    required super.challengeTags,
    required super.isVerified,
    required super.isFeatured,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.category,
    super.isLiked,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      avgCost: json['avg_cost'] != null ? double.tryParse(json['avg_cost'].toString()) : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      totalSaves: json['total_saves'] ?? 0,
      totalCheckins: json['total_checkins'] ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      openingHours:
          json['opening_hours'] != null ? Map<String, String>.from(json['opening_hours']) : null,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      aiSummary: json['ai_summary'],
      bestTimeToVisit: json['best_time_to_visit'],
      recommendedDuration: json['recommended_duration'],
      isHiddenGem: json['is_hidden_gem'] ?? false,
      challengeTags: (json['challenge_tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isVerified: json['is_verified'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      category:
          json['category'] != null ? DestinationCategoryModel.fromJson(json['category']) : null,
      isLiked: json['isLiked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'address': address,
      'lat': lat,
      'lng': lng,
      'avg_cost': avgCost,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_likes': totalLikes,
      'total_saves': totalSaves,
      'total_checkins': totalCheckins,
      'tags': tags,
      'opening_hours': openingHours,
      'images': images,
      'ai_summary': aiSummary,
      'best_time_to_visit': bestTimeToVisit,
      'recommended_duration': recommendedDuration,
      'is_hidden_gem': isHiddenGem,
      'challenge_tags': challengeTags,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category != null
          ? DestinationCategoryModel(
              id: category!.id,
              name: category!.name,
              icon: category!.icon,
              description: category!.description,
              travelStyleId: category!.travelStyleId,
              contextTags: category!.contextTags,
              popularityScore: category!.popularityScore,
              avgVisitDuration: category!.avgVisitDuration,
              isActive: category!.isActive,
              createdAt: category!.createdAt,
              updatedAt: category!.updatedAt,
            ).toJson()
          : null,
    };
  }
}

class DestinationCategoryModel extends DestinationCategory {
  const DestinationCategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    super.description,
    required super.travelStyleId,
    required super.contextTags,
    super.popularityScore,
    super.avgVisitDuration,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory DestinationCategoryModel.fromJson(Map<String, dynamic> json) {
    return DestinationCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'],
      travelStyleId: json['travel_style_id'] ?? '',
      contextTags: (json['context_tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
      avgVisitDuration: json['avg_visit_duration'],
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'travel_style_id': travelStyleId,
      'context_tags': contextTags,
      'popularity_score': popularityScore,
      'avg_visit_duration': avgVisitDuration,
      'is_active': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
