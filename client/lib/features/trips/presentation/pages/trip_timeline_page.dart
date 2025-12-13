import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';

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
  // Mock trip data - replace with API call
  final _tripData = {
    'id': '1',
    'name': 'Hà Nội - Thủ đô ngàn năm',
    'startDate': DateTime(2025, 12, 15),
    'endDate': DateTime(2025, 12, 16),
    'budget': 1500000.0,
    'totalCost': 850000.0,
    'status': 'active',
    'destinations': [
      {
        'id': '1',
        'name': 'The Ylang Coffee',
        'address': '2 Lê Thạch, Hoàn Kiếm',
        'image': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
        'time': '08:00',
        'duration': 90,
        'cost': 80000,
        'type': 'cafe',
        'notes': 'Gọi bàn trước',
      },
      {
        'id': '2',
        'name': 'Bảo tàng Mỹ Thuật Việt Nam',
        'address': '66 Nguyễn Thái Học, Ba Đình',
        'image': 'https://images.unsplash.com/photo-1531058020387-3be344556be6?w=800',
        'time': '10:00',
        'duration': 120,
        'cost': 40000,
        'type': 'museum',
        'distance': 2.5, // km from previous location
        'travelTime': 15, // minutes
      },
      {
        'id': '3',
        'name': 'Phở Thìn Bờ Hồ',
        'address': '13 Lò Đúc, Hoàn Kiếm',
        'image': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800',
        'time': '12:30',
        'duration': 60,
        'cost': 70000,
        'type': 'restaurant',
        'distance': 1.8,
        'travelTime': 10,
      },
      {
        'id': '4',
        'name': 'Hồ Hoàn Kiếm',
        'address': 'Hoàn Kiếm, Hà Nội',
        'image': 'https://images.unsplash.com/photo-1545779953-dedf51133e32?w=800',
        'time': '14:00',
        'duration': 90,
        'cost': 0,
        'type': 'attraction',
        'distance': 0.5,
        'travelTime': 5,
      },
      {
        'id': '5',
        'name': 'Hanoi Art Exhibition',
        'address': 'Tràng Tiền Plaza',
        'image': 'https://images.unsplash.com/photo-1531058020387-3be344556be6?w=800',
        'time': '16:00',
        'duration': 120,
        'cost': 50000,
        'type': 'event',
        'distance': 0.8,
        'travelTime': 8,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final totalDistance = _calculateTotalDistance();
    final totalTime = _calculateTotalTime();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),

          // Summary Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  _buildSummaryCards(totalDistance, totalTime),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Timeline
          _buildTimeline(),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
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
          _tripData['name'] as String,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                Colors.purple.withOpacity(0.2),
                AppTheme.backgroundColor,
              ],
            ),
          ),
          child: Padding(
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
                      '${DateFormat('dd/MM').format(_tripData['startDate'] as DateTime)} - ${DateFormat('dd/MM/yyyy').format(_tripData['endDate'] as DateTime)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Đang đi',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double totalDistance, int totalTime) {
    final budget = _tripData['budget'] as double;
    final totalCost = _tripData['totalCost'] as double;
    final budgetPercentage = (totalCost / budget * 100).toInt();

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.attach_money,
            title: 'Ngân sách',
            value: '${(totalCost / 1000).toStringAsFixed(0)}K',
            subtitle: 'của ${(budget / 1000).toStringAsFixed(0)}K',
            percentage: budgetPercentage / 100,
            color: budgetPercentage > 80 ? Colors.red : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.schedule,
            title: 'Thời gian',
            value: '${(totalTime / 60).toStringAsFixed(1)}h',
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
            subtitle: '${(_tripData['destinations'] as List).length} điểm',
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

  Widget _buildTimeline() {
    final destinations = _tripData['destinations'] as List;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dest = destinations[index];
          final isLast = index == destinations.length - 1;

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
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.backgroundColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast) ...[
                      // Travel info
                      if (dest['distance'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.directions_walk, size: 12, color: AppTheme.primaryColor),
                              Text(
                                '${dest['distance']}km',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${dest['travelTime']}\'',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.3),
                                AppTheme.primaryColor,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ] else
                        Container(
                          width: 2,
                          height: 100,
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                    ],
                  ],
                ),
                const SizedBox(width: 16),

                // Destination card
                Expanded(
                  child: _buildDestinationCard(dest, index),
                ),
              ],
            ),
          );
        },
        childCount: destinations.length,
      ),
    );
  }

  Widget _buildDestinationCard(Map dest, int index) {
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  dest['image'],
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
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          dest['time'],
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
                      dest['cost'] == 0 ? 'Miễn phí' : '${(dest['cost'] / 1000).toStringAsFixed(0)}K',
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
                  dest['name'],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dest['address'],
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, size: 14, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${dest['duration']} phút',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    if (dest['notes'] != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.note_outlined, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dest['notes'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.directions, size: 16),
                        label: Text(
                          'Chỉ đường',
                          style: GoogleFonts.inter(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: Text(
                          'Chi tiết',
                          style: GoogleFonts.inter(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportTrip,
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(
                  'Xuất lịch trình',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completeTrip,
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(
                  'Hoàn thành',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalDistance() {
    final destinations = _tripData['destinations'] as List;
    double total = 0;
    for (var dest in destinations) {
      total += (dest['distance'] as double?) ?? 0;
    }
    return total;
  }

  int _calculateTotalTime() {
    final destinations = _tripData['destinations'] as List;
    int total = 0;
    for (var dest in destinations) {
      total += (dest['duration'] as int?) ?? 0;
      total += (dest['travelTime'] as int?) ?? 0;
    }
    return total;
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
}

