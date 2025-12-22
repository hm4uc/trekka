import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/trip.dart' hide TripEvent;
import '../../domain/entities/trip.dart' as entities show TripEvent;
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../widgets/add_destination_to_trip_dialog.dart';

class TripTimelinePage extends StatefulWidget {
  final String tripId;

  const TripTimelinePage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripTimelinePage> createState() => _TripTimelinePageState();
}

class _TripTimelinePageState extends State<TripTimelinePage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TripBloc>()..add(GetTripDetailEvent(widget.tripId)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            if (state is TripLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            if (state is TripError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.inter(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TripBloc>().add(GetTripDetailEvent(widget.tripId));
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is TripDetailLoaded) {
              return _buildTripDetail(context, state.trip);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildTripDetail(BuildContext context, Trip trip) {
    final totalDistance = _calculateTotalDistance(trip);
    final totalTime = _calculateTotalTime(trip);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(trip),

          // Summary Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  _buildSummaryCards(trip, totalDistance, totalTime),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Timeline
          _buildTimeline(trip),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final tripBloc = context.read<TripBloc>();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => AddDestinationToTripDialog(
              tripId: trip.id,
              tripBloc: tripBloc,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_location_alt, color: Colors.black),
        label: Text(
          'Thêm điểm đến',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Trip trip) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editTrip,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareTrip,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          trip.tripTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: trip.coverImage != null && trip.coverImage!.isNotEmpty
            ? Stack(
                children: [
                  Image.network(
                    trip.coverImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildGradientBackground();
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.3),
                          Colors.purple.withValues(alpha: 0.2),
                          AppTheme.backgroundColor,
                        ],
                      ),
                    ),
                  ),
                  _buildAppBarContent(trip),
                ],
              )
            : Stack(
                children: [
                  _buildGradientBackground(),
                  _buildAppBarContent(trip),
                ],
              ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.2),
            AppTheme.backgroundColor,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarContent(Trip trip) {
    String statusText = '';
    Color statusColor = Colors.green;

    switch (trip.tripStatus) {
      case 'draft':
        statusText = 'Nháp';
        statusColor = Colors.orange;
        break;
      case 'active':
        statusText = 'Đang đi';
        statusColor = Colors.green;
        break;
      case 'completed':
        statusText = 'Hoàn thành';
        statusColor = AppTheme.textGrey;
        break;
      default:
        statusText = trip.tripStatus;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(trip.tripStartDate, 'dd/MM')} - ${_formatDate(trip.tripEndDate, 'dd/MM/yyyy')}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Trip trip, double totalDistance, int totalTime) {
    final budget = trip.tripBudget;
    final totalCost = trip.tripActualCost;
    final budgetPercentage = budget > 0 ? (totalCost / budget * 100).toInt() : 0;
    final destinationCount = (trip.tripDestinations?.length ?? 0) + (trip.tripEvents?.length ?? 0);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.attach_money,
            title: 'Ngân sách',
            value: budget > 0 ? '${(totalCost / 1000).toStringAsFixed(0)}K' : '0K',
            subtitle: budget > 0 ? 'của ${(budget / 1000).toStringAsFixed(0)}K' : 'Chưa đặt',
            percentage: budget > 0 ? budgetPercentage / 100 : null,
            color: budgetPercentage > 80 ? Colors.red : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.schedule,
            title: 'Thời gian',
            value: totalTime > 0 ? '${(totalTime / 60).toStringAsFixed(1)}h' : '0h',
            subtitle: '$totalTime phút',
            percentage: null,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.navigation,
            title: 'Quãng đường',
            value: '${totalDistance.toStringAsFixed(1)}km',
            subtitle: '$destinationCount điểm',
            percentage: null,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    double? percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textGrey,
            ),
          ),
          if (percentage != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 4,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ] else ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(Trip trip) {
    // Combine destinations and events sorted by visit_order
    final List<_TimelineItem> items = [];

    if (trip.tripDestinations != null) {
      for (var dest in trip.tripDestinations!) {
        items.add(_TimelineItem(
          type: 'destination',
          order: dest.visitOrder,
          tripDestination: dest,
        ));
      }
    }

    if (trip.tripEvents != null) {
      for (var event in trip.tripEvents!) {
        items.add(_TimelineItem(
          type: 'event',
          order: event.visitOrder,
          tripEvent: event,
        ));
      }
    }

    // Sort by visit order
    items.sort((a, b) => a.order.compareTo(b.order));

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.map_outlined, size: 60, color: AppTheme.textGrey),
                const SizedBox(height: 16),
                Text(
                  'Chưa có điểm đến nào trong lịch trình',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.type == 'event'
                            ? Colors.purple
                            : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.backgroundColor, width: 3),
                      ),
                      child: Center(
                        child: item.type == 'event'
                            ? const Icon(Icons.event, size: 18, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 100,
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Item card
                Expanded(
                  child: item.type == 'destination'
                      ? _buildDestinationCardFromEntity(item.tripDestination!)
                      : _buildEventCardFromEntity(item.tripEvent!),
                ),
              ],
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  double _calculateTotalDistance(Trip trip) {
    double total = 0;
    if (trip.tripDestinations != null) {
      for (var dest in trip.tripDestinations!) {
        if (dest.travelDistance != null) {
          total += dest.travelDistance! / 1000.0; // Convert to km
        }
      }
    }
    return total;
  }

  int _calculateTotalTime(Trip trip) {
    int total = 0;
    if (trip.tripDestinations != null) {
      for (var dest in trip.tripDestinations!) {
        total += dest.estimatedTime ?? 0;
        total += dest.travelDuration ?? 0;
      }
    }
    if (trip.tripEvents != null) {
      // Estimate 120 minutes per event
      total += trip.tripEvents!.length * 120;
    }
    return total;
  }

  Widget _buildDestinationCardFromEntity(TripDestination tripDest) {
    final dest = tripDest.destination;
    final imageUrl = dest?.images.isNotEmpty == true ? dest!.images.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: AppTheme.backgroundColor,
                        child: const Icon(Icons.image, size: 40, color: Colors.white30),
                      );
                    },
                  ),
                  // Time badge
                  if (tripDest.startTime != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              tripDest.startTime!.substring(0, 5), // HH:MM
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Cost badge
                  if (dest?.avgCost != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(dest!.avgCost! / 1000).toStringAsFixed(0)}K',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dest?.name ?? 'Điểm đến',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tripDest.estimatedTime != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined, size: 14, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        '${tripDest.estimatedTime} phút',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
                if (tripDest.notes != null && tripDest.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_outlined, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tripDest.notes!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCardFromEntity(entities.TripEvent tripEvent) {
    final event = tripEvent.event;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event, size: 12, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        'SỰ KIỆN',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event?.eventName ?? 'Sự kiện',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (event?.eventStart != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(event!.eventStart!),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ],
            if (event?.eventTicketPrice != null && event!.eventTicketPrice! > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    'Vé: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(event.eventTicketPrice)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ],
            if (tripEvent.notes != null && tripEvent.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined, size: 14, color: Colors.purple),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tripEvent.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.purple,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editTrip() {
    // TODO: Navigate to edit mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chỉnh sửa chuyến đi'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareTrip() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chia sẻ chuyến đi'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _exportTrip() {
    // TODO: Export trip as PDF/Image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang xuất lịch trình...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _completeTrip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Hoàn thành chuyến đi?',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn đánh dấu chuyến đi này là hoàn thành?',
          style: GoogleFonts.inter(color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: AppTheme.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã hoàn thành chuyến đi!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Hoàn thành',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, String format) {
    try {
      return DateFormat(format, 'vi_VN').format(date);
    } catch (e) {
      // Fallback formatting
      if (format == 'dd/MM') {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }
  }
}

// Helper class for timeline items
class _TimelineItem {
  final String type; // 'destination' or 'event'
  final int order;
  final TripDestination? tripDestination;
  final entities.TripEvent? tripEvent;

  _TimelineItem({
    required this.type,
    required this.order,
    this.tripDestination,
    this.tripEvent,
  });
}
