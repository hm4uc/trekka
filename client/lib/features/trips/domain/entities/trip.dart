import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String userId;
  final String tripTitle;
  final String? tripDescription;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final double tripBudget;
  final double tripActualCost;
  final String tripStatus; // draft, planned, ongoing, completed, cancelled
  final String tripTransport; // walking, bicycle, motorbike, car, bus, train, plane
  final String tripType; // solo, couple, family, friends, group
  final int participantCount;
  final String visibility; // private, friends, public
  final String? coverImage;
  final List<String> tags;
  final bool aiGenerated;
  final String? aiRequestId;
  final bool isTemplate;
  final int totalDistance;
  final int totalDuration;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TripDestination>? tripDestinations;
  final List<TripEvent>? tripEvents;
  final TripUser? user;

  const Trip({
    required this.id,
    required this.userId,
    required this.tripTitle,
    this.tripDescription,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.tripBudget,
    required this.tripActualCost,
    required this.tripStatus,
    required this.tripTransport,
    required this.tripType,
    required this.participantCount,
    required this.visibility,
    this.coverImage,
    required this.tags,
    required this.aiGenerated,
    this.aiRequestId,
    required this.isTemplate,
    required this.totalDistance,
    required this.totalDuration,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.tripDestinations,
    this.tripEvents,
    this.user,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        tripTitle,
        tripDescription,
        tripStartDate,
        tripEndDate,
        tripBudget,
        tripActualCost,
        tripStatus,
        tripTransport,
        tripType,
        participantCount,
        visibility,
        coverImage,
        tags,
        aiGenerated,
        aiRequestId,
        isTemplate,
        totalDistance,
        totalDuration,
        metadata,
        createdAt,
        updatedAt,
        tripDestinations,
        tripEvents,
        user,
      ];
}

class TripDestination extends Equatable {
  final String? id;
  final String? tripId;
  final String? destId;
  final int visitOrder;
  final int? estimatedTime;
  final int? actualTime;
  final DateTime? visitDate;
  final String? startTime;
  final String? notes;
  final bool isCompleted;
  final int? travelDistance;
  final int? travelDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DestinationInfo? destination;

  const TripDestination({
    this.id,
    this.tripId,
    this.destId,
    required this.visitOrder,
    this.estimatedTime,
    this.actualTime,
    this.visitDate,
    this.startTime,
    this.notes,
    required this.isCompleted,
    this.travelDistance,
    this.travelDuration,
    this.createdAt,
    this.updatedAt,
    this.destination,
  });

  @override
  List<Object?> get props => [
        id,
        tripId,
        destId,
        visitOrder,
        estimatedTime,
        actualTime,
        visitDate,
        startTime,
        notes,
        isCompleted,
        travelDistance,
        travelDuration,
        createdAt,
        updatedAt,
        destination,
      ];
}

class TripEvent extends Equatable {
  final String? id;
  final String? tripId;
  final String? eventId;
  final int visitOrder;
  final String? notes;
  final bool isCompleted;
  final bool reminderSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EventInfo? event;

  const TripEvent({
    this.id,
    this.tripId,
    this.eventId,
    required this.visitOrder,
    this.notes,
    required this.isCompleted,
    required this.reminderSent,
    this.createdAt,
    this.updatedAt,
    this.event,
  });

  @override
  List<Object?> get props => [
        id,
        tripId,
        eventId,
        visitOrder,
        notes,
        isCompleted,
        reminderSent,
        createdAt,
        updatedAt,
        event,
      ];
}

class TripUser extends Equatable {
  final String id;
  final String fullname;
  final String? avatar;

  const TripUser({
    required this.id,
    required this.fullname,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, fullname, avatar];
}

class DestinationInfo extends Equatable {
  final String id;
  final String name;
  final List<String> images;
  final double? lat;
  final double? lng;
  final double? avgCost;

  const DestinationInfo({
    required this.id,
    required this.name,
    required this.images,
    this.lat,
    this.lng,
    this.avgCost,
  });

  @override
  List<Object?> get props => [id, name, images, lat, lng, avgCost];
}

class EventInfo extends Equatable {
  final String id;
  final String eventName;
  final DateTime? eventStart;
  final DateTime? eventEnd;
  final double? eventTicketPrice;

  const EventInfo({
    required this.id,
    required this.eventName,
    this.eventStart,
    this.eventEnd,
    this.eventTicketPrice,
  });

  @override
  List<Object?> get props => [id, eventName, eventStart, eventEnd, eventTicketPrice];
}
