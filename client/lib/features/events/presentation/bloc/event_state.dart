import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoadingMore extends EventState {
  final List<Event> currentEvents;

  const EventLoadingMore(this.currentEvents);

  @override
  List<Object?> get props => [currentEvents];
}

class EventLoaded extends EventState {
  final List<Event> events;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  const EventLoaded({
    required this.events,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [events, currentPage, totalPages, total, hasMore];

  EventLoaded copyWith({
    List<Event>? events,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
  }) {
    return EventLoaded(
      events: events ?? this.events,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class UpcomingEventsLoading extends EventState {}

class UpcomingEventsLoaded extends EventState {
  final List<Event> events;

  const UpcomingEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventActionSuccess extends EventState {
  final String message;
  final Event? event;

  const EventActionSuccess(this.message, {this.event});

  @override
  List<Object?> get props => [message, event];
}

