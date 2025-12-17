import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String eventName;
  final String eventDescription;
  final String eventLocation;
  final double lat;
  final double lng;
  final DateTime eventStart;
  final DateTime eventEnd;
  final double eventTicketPrice;
  final String eventType;
  final String eventOrganizer;
  final int eventCapacity;
  final List<String> eventTags;
  final List<String> images;
  final String? contactInfo;
  final int totalAttendees;
  final int totalLikes;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.eventLocation,
    required this.lat,
    required this.lng,
    required this.eventStart,
    required this.eventEnd,
    required this.eventTicketPrice,
    required this.eventType,
    required this.eventOrganizer,
    required this.eventCapacity,
    required this.eventTags,
    required this.images,
    this.contactInfo,
    required this.totalAttendees,
    required this.totalLikes,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        eventName,
        eventDescription,
        eventLocation,
        lat,
        lng,
        eventStart,
        eventEnd,
        eventTicketPrice,
        eventType,
        eventOrganizer,
        eventCapacity,
        eventTags,
        images,
        contactInfo,
        totalAttendees,
        totalLikes,
        isActive,
        isFeatured,
        createdAt,
        updatedAt,
      ];
}

