import '../../domain/entities/trip.dart';

class TripModel {
  final String id;
  final String userId;
  final String tripTitle;
  final String? tripDescription;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final double tripBudget;
  final double tripActualCost;
  final String tripStatus;
  final String tripTransport;
  final String tripType;
  final int participantCount;
  final String visibility;
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

  const TripModel({
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

  Trip toEntity() {
    return Trip(
      id: id,
      userId: userId,
      tripTitle: tripTitle,
      tripDescription: tripDescription,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      tripBudget: tripBudget,
      tripActualCost: tripActualCost,
      tripStatus: tripStatus,
      tripTransport: tripTransport,
      tripType: tripType,
      participantCount: participantCount,
      visibility: visibility,
      coverImage: coverImage,
      tags: tags,
      aiGenerated: aiGenerated,
      aiRequestId: aiRequestId,
      isTemplate: isTemplate,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tripDestinations: tripDestinations,
      tripEvents: tripEvents,
      user: user,
    );
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    Map<String, dynamic> tripData;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      tripData = json['data'] as Map<String, dynamic>;
    } else {
      tripData = json;
    }

    return TripModel(
      id: tripData['id'] ?? '',
      userId: tripData['user_id'] ?? '',
      tripTitle: tripData['trip_title'] ?? '',
      tripDescription: tripData['trip_description'],
      tripStartDate: DateTime.parse(tripData['trip_start_date']),
      tripEndDate: DateTime.parse(tripData['trip_end_date']),
      tripBudget: _parseDouble(tripData['trip_budget']),
      tripActualCost: _parseDouble(tripData['trip_actual_cost']),
      tripStatus: tripData['trip_status'] ?? 'draft',
      tripTransport: tripData['trip_transport'] ?? 'walking',
      tripType: tripData['trip_type'] ?? 'solo',
      participantCount: tripData['participant_count'] ?? 1,
      visibility: tripData['visibility'] ?? 'private',
      coverImage: tripData['cover_image'],
      tags: (tripData['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      aiGenerated: tripData['ai_generated'] ?? false,
      aiRequestId: tripData['ai_request_id'],
      isTemplate: tripData['is_template'] ?? false,
      totalDistance: tripData['total_distance'] ?? 0,
      totalDuration: tripData['total_duration'] ?? 0,
      metadata: tripData['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(tripData['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(tripData['updatedAt'] ?? DateTime.now().toIso8601String()),
      tripDestinations: (tripData['tripDestinations'] as List?)
          ?.map((e) => TripDestinationModel.fromJson(e).toEntity())
          .toList(),
      tripEvents: (tripData['tripEvents'] as List?)?.map((e) => TripEventModel.fromJson(e).toEntity()).toList(),
      user: tripData['user'] != null ? TripUserModel.fromJson(tripData['user']).toEntity() : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trip_title': tripTitle,
      'trip_description': tripDescription,
      'trip_start_date': tripStartDate.toIso8601String().split('T')[0],
      'trip_end_date': tripEndDate.toIso8601String().split('T')[0],
      'trip_budget': tripBudget,
      'trip_actual_cost': tripActualCost,
      'trip_status': tripStatus,
      'trip_transport': tripTransport,
      'trip_type': tripType,
      'participant_count': participantCount,
      'visibility': visibility,
      'cover_image': coverImage,
      'tags': tags,
      'ai_generated': aiGenerated,
      'ai_request_id': aiRequestId,
      'is_template': isTemplate,
      'total_distance': totalDistance,
      'total_duration': totalDuration,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TripDestinationModel {
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

  const TripDestinationModel({
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

  TripDestination toEntity() {
    return TripDestination(
      id: id,
      tripId: tripId,
      destId: destId,
      visitOrder: visitOrder,
      estimatedTime: estimatedTime,
      actualTime: actualTime,
      visitDate: visitDate,
      startTime: startTime,
      notes: notes,
      isCompleted: isCompleted,
      travelDistance: travelDistance,
      travelDuration: travelDuration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      destination: destination,
    );
  }

  factory TripDestinationModel.fromJson(Map<String, dynamic> json) {
    return TripDestinationModel(
      id: json['id'],
      tripId: json['trip_id'],
      destId: json['dest_id'],
      visitOrder: json['visit_order'] ?? 0,
      estimatedTime: json['estimated_time'],
      actualTime: json['actual_time'],
      visitDate: json['visit_date'] != null ? DateTime.parse(json['visit_date']) : null,
      startTime: json['start_time'],
      notes: json['notes'],
      isCompleted: json['is_completed'] ?? false,
      travelDistance: json['travel_distance'],
      travelDuration: json['travel_duration'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      destination: json['destination'] != null ? DestinationInfoModel.fromJson(json['destination']).toEntity() : null,
    );
  }
}

class TripEventModel {
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

  const TripEventModel({
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

  TripEvent toEntity() {
    return TripEvent(
      id: id,
      tripId: tripId,
      eventId: eventId,
      visitOrder: visitOrder,
      notes: notes,
      isCompleted: isCompleted,
      reminderSent: reminderSent,
      createdAt: createdAt,
      updatedAt: updatedAt,
      event: event,
    );
  }

  factory TripEventModel.fromJson(Map<String, dynamic> json) {
    return TripEventModel(
      id: json['id'],
      tripId: json['trip_id'],
      eventId: json['event_id'],
      visitOrder: json['visit_order'] ?? 0,
      notes: json['notes'],
      isCompleted: json['is_completed'] ?? false,
      reminderSent: json['reminder_sent'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      event: json['event'] != null ? EventInfoModel.fromJson(json['event']).toEntity() : null,
    );
  }
}

class TripUserModel {
  final String id;
  final String fullname;
  final String? avatar;

  const TripUserModel({
    required this.id,
    required this.fullname,
    this.avatar,
  });

  TripUser toEntity() {
    return TripUser(
      id: id,
      fullname: fullname,
      avatar: avatar,
    );
  }

  factory TripUserModel.fromJson(Map<String, dynamic> json) {
    return TripUserModel(
      id: json['id'] ?? '',
      fullname: json['usr_fullname'] ?? '',
      avatar: json['usr_avatar'],
    );
  }
}

class DestinationInfoModel {
  final String id;
  final String name;
  final List<String> images;
  final double? lat;
  final double? lng;
  final double? avgCost;

  const DestinationInfoModel({
    required this.id,
    required this.name,
    required this.images,
    this.lat,
    this.lng,
    this.avgCost,
  });

  DestinationInfo toEntity() {
    return DestinationInfo(
      id: id,
      name: name,
      images: images,
      lat: lat,
      lng: lng,
      avgCost: avgCost,
    );
  }

  factory DestinationInfoModel.fromJson(Map<String, dynamic> json) {
    return DestinationInfoModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      avgCost: json['avg_cost'] != null ? double.tryParse(json['avg_cost'].toString()) : null,
    );
  }
}

class EventInfoModel {
  final String id;
  final String eventName;
  final DateTime? eventStart;
  final DateTime? eventEnd;
  final double? eventTicketPrice;

  const EventInfoModel({
    required this.id,
    required this.eventName,
    this.eventStart,
    this.eventEnd,
    this.eventTicketPrice,
  });

  EventInfo toEntity() {
    return EventInfo(
      id: id,
      eventName: eventName,
      eventStart: eventStart,
      eventEnd: eventEnd,
      eventTicketPrice: eventTicketPrice,
    );
  }

  factory EventInfoModel.fromJson(Map<String, dynamic> json) {
    return EventInfoModel(
      id: json['id'] ?? '',
      eventName: json['event_name'] ?? '',
      eventStart: json['event_start'] != null ? DateTime.parse(json['event_start']) : null,
      eventEnd: json['event_end'] != null ? DateTime.parse(json['event_end']) : null,
      eventTicketPrice: json['event_ticket_price'] != null ? double.tryParse(json['event_ticket_price'].toString()) : null,
    );
  }
}
