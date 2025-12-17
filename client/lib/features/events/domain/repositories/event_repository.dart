import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';

abstract class EventRepository {
  /// Get events with filters
  Future<Either<Failure, EventsResult>> getEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? eventType,
    double? lat,
    double? lng,
    double radius = 5000,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  });

  /// Get upcoming events
  Future<Either<Failure, List<Event>>> getUpcomingEvents({
    double? lat,
    double? lng,
    double radius = 5000,
    int limit = 10,
  });

  /// Get event detail by ID
  Future<Either<Failure, Event>> getEventById(String id);

  /// Like an event
  Future<Either<Failure, Map<String, dynamic>>> likeEvent(String id);

  /// Check-in at an event
  Future<Either<Failure, Event>> checkinEvent(String id);
}

class EventsResult {
  final int total;
  final int currentPage;
  final int totalPages;
  final List<Event> events;

  EventsResult({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.events,
  });
}

