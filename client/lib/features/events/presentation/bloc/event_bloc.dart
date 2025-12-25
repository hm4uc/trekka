import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/checkin_event.dart';
import '../../domain/usecases/get_event_by_id.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/get_upcoming_events.dart';
import '../../domain/usecases/like_event.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventBlocEvent, EventState> {
  final GetEvents getEvents;
  final GetUpcomingEvents getUpcomingEvents;
  final GetEventById getEventById;
  final LikeEvent likeEvent;
  final CheckinEvent checkinEvent;

  EventBloc({
    required this.getEvents,
    required this.getUpcomingEvents,
    required this.getEventById,
    required this.likeEvent,
    required this.checkinEvent,
  }) : super(EventInitial()) {
    on<GetEventsEvent>(_onGetEvents);
    on<GetUpcomingEventsEvent>(_onGetUpcomingEvents);
    on<SetEventDetailEvent>(_onSetEventDetail);
    on<LikeEventEvent>(_onLikeEvent);
    on<CheckinEventEvent>(_onCheckinEvent);
  }

  Future<void> _onGetEvents(
    GetEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    // If loading more, show loading state with current data
    if (event.loadMore && state is EventLoaded) {
      final currentState = state as EventLoaded;
      emit(EventLoadingMore(currentState.events));
    } else {
      emit(EventLoading());
    }

    final params = GetEventsParams(
      page: event.page,
      limit: event.limit,
      search: event.search,
      eventType: event.eventType,
      lat: event.lat,
      lng: event.lng,
      radius: event.radius,
      startDate: event.startDate,
      endDate: event.endDate,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      sortBy: event.sortBy,
    );

    final result = await getEvents(params);

    result.fold(
      (failure) => emit(EventError(failure.message)),
      (eventsResult) {
        final hasMore = eventsResult.currentPage < eventsResult.totalPages;

        // If loading more, append to existing list
        if (event.loadMore && state is EventLoadingMore) {
          final currentState = state as EventLoadingMore;
          final updatedEvents = [
            ...currentState.currentEvents,
            ...eventsResult.events,
          ];

          emit(EventLoaded(
            events: updatedEvents,
            currentPage: eventsResult.currentPage,
            totalPages: eventsResult.totalPages,
            total: eventsResult.total,
            hasMore: hasMore,
          ));
        } else {
          emit(EventLoaded(
            events: eventsResult.events,
            currentPage: eventsResult.currentPage,
            totalPages: eventsResult.totalPages,
            total: eventsResult.total,
            hasMore: hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onGetUpcomingEvents(
    GetUpcomingEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(UpcomingEventsLoading());

    final result = await getUpcomingEvents(
      lat: event.lat,
      lng: event.lng,
      radius: event.radius,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(UpcomingEventsLoaded(events)),
    );
  }

  Future<void> _onSetEventDetail(
    SetEventDetailEvent event,
    Emitter<EventState> emit,
  ) async {
    // Reload event from API to get fresh isLiked status
    // because event from list may not have isLiked field
    final result = await getEventById(event.event.id);

    result.fold(
      (failure) {
        // Fallback to initial event if API fails
        emit(EventDetailLoaded(
          event: event.event,
          isLiked: event.event.isLiked ?? false,
        ));
      },
      (freshEvent) {
        emit(EventDetailLoaded(
          event: freshEvent,
          isLiked: freshEvent.isLiked ?? false,
        ));
      },
    );
  }

  Future<void> _onLikeEvent(
    LikeEventEvent event,
    Emitter<EventState> emit,
  ) async {
    // If we have EventDetailLoaded state, do optimistic update
    if (state is EventDetailLoaded) {
      final currentState = state as EventDetailLoaded;
      final isCurrentlyLiked = currentState.isLiked;

      // Optimistically update UI
      emit(currentState.copyWith(isLiked: !isCurrentlyLiked));

      final result = await likeEvent(event.eventId);

      result.fold(
        (failure) {
          // Revert on failure
          emit(currentState.copyWith(isLiked: isCurrentlyLiked));
          emit(EventError(failure.message));
        },
        (response) {
          final isLiked = response['isLiked'] as bool;
          // Keep the optimistic update
          emit(EventActionSuccess(isLiked ? 'Đã like sự kiện' : 'Đã bỏ like sự kiện'));
          // Restore the loaded state after showing success
          Future.delayed(const Duration(seconds: 1), () {
            if (state is EventActionSuccess) {
              emit(currentState.copyWith(isLiked: isLiked));
            }
          });
        },
      );
    } else {
      // Legacy behavior for list views
      final result = await likeEvent(event.eventId);

      result.fold(
        (failure) => emit(EventError(failure.message)),
        (response) {
          final isLiked = response['isLiked'] as bool;
          emit(EventActionSuccess(isLiked ? 'Đã like sự kiện' : 'Đã bỏ like sự kiện'));
        },
      );
    }
  }

  Future<void> _onCheckinEvent(
    CheckinEventEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await checkinEvent(event.eventId);

    result.fold(
      (failure) => emit(EventError(failure.message)),
      (updatedEvent) {

        emit(EventActionSuccess('Check-in thành công', event: updatedEvent));
      },
    );
  }
}

