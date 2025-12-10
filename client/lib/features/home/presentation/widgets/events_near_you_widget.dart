import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';

class Event {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String category;

  Event({
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.category,
  });
}

class EventsNearYouWidget extends StatelessWidget {
  final List<Event> events;

  const EventsNearYouWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events
          .map((event) => _buildEventCard(context, event))
          .toList(),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Event Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              event.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: AppTheme.backgroundColor,
                child: const Icon(Icons.event, color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.category,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Event Title
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Date & Location
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      event.date,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 12, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Icon
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

