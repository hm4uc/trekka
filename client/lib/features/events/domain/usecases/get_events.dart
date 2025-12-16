import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/event_repository.dart';

class GetEvents {
  final EventRepository repository;

  GetEvents(this.repository);

  Future<Either<Failure, EventsResult>> call(GetEventsParams params) async {
    return await repository.getEvents(
      page: params.page,
      limit: params.limit,
      search: params.search,
      eventType: params.eventType,
      lat: params.lat,
      lng: params.lng,
      radius: params.radius,
      startDate: params.startDate,
      endDate: params.endDate,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      sortBy: params.sortBy,
    );
  }
}

class GetEventsParams {
  final int page;
  final int limit;
  final String? search;
  final String? eventType;
  final double? lat;
  final double? lng;
  final double radius;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  GetEventsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.eventType,
    this.lat,
    this.lng,
    this.radius = 5000,
    this.startDate,
    this.endDate,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });
}

