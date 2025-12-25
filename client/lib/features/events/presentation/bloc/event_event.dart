import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventBlocEvent extends Equatable {
  const EventBlocEvent();

  @override
  List<Object?> get props => [];
}

class GetEventsEvent extends EventBlocEvent {
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
  final bool loadMore;

  const GetEventsEvent({
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
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        search,
        eventType,
        lat,
        lng,
        radius,
        startDate,
        endDate,
        minPrice,
        maxPrice,
        sortBy,
        loadMore,
      ];
}

class GetUpcomingEventsEvent extends EventBlocEvent {
  final double? lat;
  final double? lng;
  final double radius;
  final int limit;

  const GetUpcomingEventsEvent({
    this.lat,
    this.lng,
    this.radius = 5000,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [lat, lng, radius, limit];
}

class SetEventDetailEvent extends EventBlocEvent {
  final Event event;

  const SetEventDetailEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class LikeEventEvent extends EventBlocEvent {
  final String eventId;

  const LikeEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class CheckinEventEvent extends EventBlocEvent {
  final String eventId;

  const CheckinEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

