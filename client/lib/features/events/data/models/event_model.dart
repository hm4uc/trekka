import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.eventName,
    required super.eventDescription,
    required super.eventLocation,
    required super.lat,
    required super.lng,
    required super.eventStart,
    required super.eventEnd,
    required super.eventTicketPrice,
    required super.eventType,
    required super.eventOrganizer,
    required super.eventCapacity,
    required super.eventTags,
    required super.images,
    super.contactInfo,
    required super.totalAttendees,
    required super.totalLikes,
    required super.isActive,
    required super.isFeatured,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      eventName: json['event_name'] as String,
      eventDescription: json['event_description'] as String,
      eventLocation: json['event_location'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      eventStart: DateTime.parse(json['event_start'] as String),
      eventEnd: DateTime.parse(json['event_end'] as String),
      eventTicketPrice: double.parse(json['event_ticket_price'].toString()),
      eventType: json['event_type'] as String,
      eventOrganizer: json['event_organizer'] as String,
      eventCapacity: json['event_capacity'] as int,
      eventTags: (json['event_tags'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      contactInfo: json['contact_info'] as String?,
      totalAttendees: json['total_attendees'] as int,
      totalLikes: json['total_likes'] as int,
      isActive: json['is_active'] as bool,
      isFeatured: json['is_featured'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_location': eventLocation,
      'lat': lat,
      'lng': lng,
      'event_start': eventStart.toIso8601String(),
      'event_end': eventEnd.toIso8601String(),
      'event_ticket_price': eventTicketPrice,
      'event_type': eventType,
      'event_organizer': eventOrganizer,
      'event_capacity': eventCapacity,
      'event_tags': eventTags,
      'images': images,
      'contact_info': contactInfo,
      'total_attendees': totalAttendees,
      'total_likes': totalLikes,
      'is_active': isActive,
      'is_featured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

