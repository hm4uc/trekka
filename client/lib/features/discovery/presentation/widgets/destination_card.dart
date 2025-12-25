import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/destination-detail/${destination.id}', extra: destination);
      },
      child: Hero(
        tag: 'destination_${destination.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                _buildImage(),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          destination.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppTheme.textGrey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destination.address,
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
                        const Spacer(),

                        // Rating & Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: destination.totalReviews > 0
                                      ? AppTheme.primaryColor
                                      : AppTheme.textGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  destination.totalReviews > 0
                                      ? destination.rating.toStringAsFixed(1)
                                      : '0.0',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: destination.totalReviews > 0
                                        ? Colors.white
                                        : AppTheme.textGrey,
                                  ),
                                ),
                              ],
                            ),
                            if (destination.avgCost != null)
                              Text(
                                _formatPrice(destination.avgCost!),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: destination.images.isNotEmpty
              ? Image.network(
                  destination.images.first,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
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
                  height: 140,
                  color: AppTheme.backgroundColor,
                  child: const Icon(
                    Icons.place,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
        ),

        // Badges
        if (destination.isHiddenGem || destination.isVerified)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: destination.isHiddenGem
                    ? Colors.purple.withOpacity(0.9)
                    : AppTheme.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    destination.isHiddenGem ? Icons.diamond : Icons.verified,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    destination.isHiddenGem ? "Hidden Gem" : "Verified",
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
  }
}
