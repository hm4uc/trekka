import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../events/domain/entities/event.dart';

class FavoriteItemCard extends StatelessWidget {
  final dynamic item; // Can be Destination or Event
  final VoidCallback? onTap;

  const FavoriteItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  bool get isEvent => item is Event;

  @override
  Widget build(BuildContext context) {
    if (isEvent) {
      return _buildEventCard(item as Event);
    } else {
      return _buildDestinationCard(item as Destination);
    }
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: event.images.isNotEmpty
                  ? Image.network(
                      event.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.event,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.backgroundColor,
                      child: const Icon(
                        Icons.event,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(event.eventStart),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Event type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getEventTypeLabel(event.eventType),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Likes
                      Icon(
                        Icons.favorite,
                        size: 12,
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
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textGrey,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: destination.images.isNotEmpty
                    ? Image.network(
                        destination.images.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.backgroundColor,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppTheme.textGrey,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.backgroundColor,
                        child: const Icon(
                          Icons.place,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.address,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Check-in count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${destination.totalCheckins} lần',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
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
}

