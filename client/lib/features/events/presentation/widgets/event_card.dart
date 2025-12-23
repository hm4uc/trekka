import 'package:easy_localization/easy_localization.dart' hide DateFormat, NumberFormat;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_themes.dart';
import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          // Navigate to event detail using GoRouter
          context.push('/event-detail/${event.id}', extra: event);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (event.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      event.images.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.event,
                            color: AppTheme.primaryColor,
                            size: 64,
                          ),
                        );
                      },
                    ),
                    // Event Type Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(event.eventType),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getEventTypeLabel(event.eventType),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Featured Badge
                    if (event.isFeatured)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Event Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  Text(
                    event.eventName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date & Time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatEventDate(event.eventStart, event.eventEnd),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.eventLocation,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats Row
                  Row(
                    children: [
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatPrice(event.eventTicketPrice),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Likes
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.totalLikes}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Attendees
                      const Icon(
                        Icons.people,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.totalAttendees}/${event.eventCapacity}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'festival':
        return Colors.purple;
      case 'concert':
        return Colors.pink;
      case 'exhibition':
        return Colors.blue;
      case 'workshop':
        return Colors.green;
      case 'conference':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getEventTypeLabel(String type) {
    switch (type) {
      case 'festival':
        return 'Lễ hội';
      case 'concert':
        return 'Hòa nhạc';
      case 'exhibition':
        return 'Triển lãm';
      case 'workshop':
        return 'Workshop';
      case 'conference':
        return 'Hội nghị';
      default:
        return type.toUpperCase();
    }
  }

  String _formatEventDate(DateTime start, DateTime end) {
    final dateFormat = intl.DateFormat('dd/MM/yyyy');
    final timeFormat = intl.DateFormat('HH:mm');

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      // Same day
      return '${dateFormat.format(start)} • ${timeFormat.format(start)} - ${timeFormat.format(end)}';
    } else {
      // Different days
      return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
    }
  }

  String _formatPrice(double price) {
    if (price == 0) {
      return 'free'.tr();
    }
    final formatter = intl.NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)}đ';
  }
}

