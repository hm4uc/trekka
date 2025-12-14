import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String name;
  final String description;
  final String location;
  final double lat;
  final double lng;
  final DateTime startTime;
  final DateTime endTime;
  final double? ticketPrice;
  final List<String> images;
  final String? category;
  final bool isFeatured;
  final bool isActive;
  final int totalAttendees;
  final String? organizerName;
  final String? organizerContact;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.lat,
    required this.lng,
    required this.startTime,
    required this.endTime,
    this.ticketPrice,
    required this.images,
    this.category,
    required this.isFeatured,
    required this.isActive,
    required this.totalAttendees,
    this.organizerName,
    this.organizerContact,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        lat,
        lng,
        startTime,
        endTime,
        ticketPrice,
        images,
        category,
        isFeatured,
        isActive,
        totalAttendees,
        organizerName,
        organizerContact,
      ];

  bool get isHappening {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  bool get isPast {
    return DateTime.now().isAfter(endTime);
  }

  Duration get timeUntilStart {
    return startTime.difference(DateTime.now());
  }

  Duration get timeUntilEnd {
    return endTime.difference(DateTime.now());
  }
}

