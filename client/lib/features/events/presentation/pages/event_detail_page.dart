import 'package:easy_localization/easy_localization.dart' hide DateFormat, NumberFormat;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/theme/app_themes.dart';
import '../../domain/entities/event.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            _buildEventInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (event.images.isNotEmpty)
              Image.network(
                event.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.surfaceColor,
                    child: const Icon(
                      Icons.event,
                      size: 100,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              )
            else
              Container(
                color: AppTheme.surfaceColor,
                child: const Icon(
                  Icons.event,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Type & Featured Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.eventType).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getEventTypeLabel(event.eventType),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getEventTypeColor(event.eventType),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (event.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          'Nổi bật',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Event Name
            Text(
              event.eventName,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                _buildStatItem(
                  Icons.favorite,
                  '${event.totalLikes}',
                  Colors.red.shade400,
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  Icons.people,
                  '${event.totalAttendees}/${event.eventCapacity}',
                  AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date & Time
            _buildInfoSection(
              Icons.calendar_today,
              'Thời gian',
              _formatEventDate(event.eventStart, event.eventEnd),
            ),
            const SizedBox(height: 16),

            // Location
            _buildInfoSection(
              Icons.location_on,
              'Địa điểm',
              event.eventLocation,
            ),
            const SizedBox(height: 16),

            // Organizer
            _buildInfoSection(
              Icons.business,
              'Ban tổ chức',
              event.eventOrganizer,
            ),
            const SizedBox(height: 16),

            // Price
            _buildInfoSection(
              Icons.attach_money,
              'Giá vé',
              _formatPrice(event.eventTicketPrice),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Mô tả',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.eventDescription,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            if (event.eventTags.isNotEmpty) ...[
              Text(
                'Tags',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.eventTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<EventBloc>().add(LikeEventEvent(event.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade400),
                      ),
                    ),
                    icon: Icon(Icons.favorite_border, color: Colors.red.shade400),
                    label: Text(
                      'Yêu thích',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<EventBloc>().add(CheckinEventEvent(event.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.black),
                    label: Text(
                      'Check-in',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      return '${dateFormat.format(start)}\n${timeFormat.format(start)} - ${timeFormat.format(end)}';
    } else {
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

