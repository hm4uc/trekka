import 'package:equatable/equatable.dart';

class Destination extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final double? avgCost;
  final double rating;
  final int totalReviews;
  final int totalLikes;
  final int totalSaves;
  final int totalCheckins;
  final List<String> tags;
  final Map<String, String>? openingHours;
  final List<String> images;
  final String? aiSummary;
  final String? bestTimeToVisit;
  final int? recommendedDuration;
  final bool isHiddenGem;
  final List<String> challengeTags;
  final bool isVerified;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DestinationCategory? category;
  final bool? isLiked; // User's like status (only present when authenticated)

  const Destination({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    this.avgCost,
    required this.rating,
    required this.totalReviews,
    required this.totalLikes,
    required this.totalSaves,
    required this.totalCheckins,
    required this.tags,
    this.openingHours,
    required this.images,
    this.aiSummary,
    this.bestTimeToVisit,
    this.recommendedDuration,
    required this.isHiddenGem,
    required this.challengeTags,
    required this.isVerified,
    required this.isFeatured,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.isLiked,
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        description,
        address,
        lat,
        lng,
        avgCost,
        rating,
        totalReviews,
        totalLikes,
        totalSaves,
        totalCheckins,
        tags,
        openingHours,
        images,
        aiSummary,
        bestTimeToVisit,
        recommendedDuration,
        isHiddenGem,
        challengeTags,
        isVerified,
        isFeatured,
        isActive,
        createdAt,
        updatedAt,
        category,
        isLiked,
      ];
}

class DestinationCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String? description;
  final String travelStyleId;
  final List<String> contextTags;
  final double? popularityScore;
  final int? avgVisitDuration;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DestinationCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    required this.travelStyleId,
    required this.contextTags,
    this.popularityScore,
    this.avgVisitDuration,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        description,
        travelStyleId,
        contextTags,
        popularityScore,
        avgVisitDuration,
        isActive,
        createdAt,
        updatedAt,
      ];
}
