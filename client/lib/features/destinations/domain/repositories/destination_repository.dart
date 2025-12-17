import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/destination.dart';

abstract class DestinationRepository {
  /// Get destinations with filters
  Future<Either<Failure, DestinationsResult>> getDestinations({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? lat,
    double? lng,
    double radius = 5000,
    bool? isOpenNow,
    String? context,
    String sortBy = 'distance',
    bool? hiddenGemsOnly,
  });

  /// Get destination detail by ID
  Future<Either<Failure, Destination>> getDestinationById(String id);

  /// Get nearby destinations
  Future<Either<Failure, List<Destination>>> getNearbyDestinations(
    String id, {
    int limit = 5,
    double radius = 2000,
  });

  /// Like a destination
  Future<Either<Failure, int>> likeDestination(String id);

  /// Save a destination to favorites
  Future<Either<Failure, int>> saveDestination(String id);

  /// Check-in at a destination
  Future<Either<Failure, int>> checkinDestination(String id);

  /// Get all categories
  Future<Either<Failure, List<DestinationCategory>>> getCategories();

  /// Get categories by travel style
  Future<Either<Failure, List<DestinationCategory>>> getCategoriesByTravelStyle(
      String travelStyle);

  /// Get liked items (destinations/events)
  Future<Either<Failure, UserActivityResult>> getLikedItems({
    int page = 1,
    int limit = 10,
    String? type,
  });

  /// Get checked-in items (destinations/events)
  Future<Either<Failure, UserActivityResult>> getCheckedInItems({
    int page = 1,
    int limit = 10,
    String? type,
  });
}

class DestinationsResult {
  final int total;
  final int currentPage;
  final int totalPages;
  final List<Destination> destinations;

  DestinationsResult({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.destinations,
  });
}

class UserActivityResult {
  final int total;
  final int currentPage;
  final int totalPages;
  final List<Destination> items;

  UserActivityResult({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.items,
  });
}
