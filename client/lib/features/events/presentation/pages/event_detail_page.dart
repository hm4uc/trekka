import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  // Mock data - replace with API call
  final _event = {
    'id': '1',
    'name': 'Hanoi Art Exhibition 2025',
    'description': 'Triển lãm nghệ thuật quy tụ các họa sĩ nổi tiếng trong nước và quốc tế. Trưng bày hơn 100 tác phẩm nghệ thuật đương đại.',
    'location': 'Tràng Tiền Plaza, Hoàn Kiếm, Hà Nội',
    'startTime': DateTime(2025, 12, 15, 15, 0),
    'endTime': DateTime(2025, 12, 15, 21, 0),
    'ticketPrice': 50000.0,
    'image': 'https://images.unsplash.com/photo-1531058020387-3be344556be6?w=800',
    'category': 'Nghệ thuật',
    'organizer': 'Hanoi Art Center',
    'attendees': 245,
    'maxCapacity': 500,
  };

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateTimeRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final startTime = _event['startTime'] as DateTime;

    setState(() {
      if (now.isBefore(startTime)) {
        _timeRemaining = startTime.difference(now);
      } else {
        _timeRemaining = Duration.zero;
        _countdownTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildCountdownSection(),
                const SizedBox(height: 16),
                _buildEventInfo(),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 16),
                _buildLocationSection(),
                const SizedBox(height: 16),
                _buildAttendeesSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
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
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareEvent,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _event['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.surfaceColor,
                  child: const Icon(Icons.event, size: 100, color: Colors.white30),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.backgroundColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final startTime = _event['startTime'] as DateTime;
    final endTime = _event['endTime'] as DateTime;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _event['category'] as String,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _event['name'] as String,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('dd/MM/yyyy').format(startTime)} • ${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _event['location'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection() {
    if (_timeRemaining == Duration.zero) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Text(
                'Sự kiện đang diễn ra',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.2),
              Colors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              'Sự kiện bắt đầu sau',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountdownItem(days.toString(), 'Ngày'),
                _buildCountdownItem(hours.toString().padLeft(2, '0'), 'Giờ'),
                _buildCountdownItem(minutes.toString().padLeft(2, '0'), 'Phút'),
                _buildCountdownItem(seconds.toString().padLeft(2, '0'), 'Giây'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownItem(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard(
            Icons.confirmation_number,
            'Giá vé',
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                .format(_event['ticketPrice']),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.business,
            'Ban tổ chức',
            _event['organizer'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
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
              color: AppTheme.primaryColor.withOpacity(0.2),
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
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Về sự kiện này',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _event['description'] as String,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Địa điểm',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _event['location'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Open map
                  },
                  icon: const Icon(
                    Icons.directions,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection() {
    final attendees = _event['attendees'] as int;
    final maxCapacity = _event['maxCapacity'] as int;
    final percentage = (attendees / maxCapacity * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Người tham gia',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$attendees/$maxCapacity',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: attendees / maxCapacity,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 80 ? Colors.red : AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              percentage > 80
                  ? 'Chỉ còn ${maxCapacity - attendees} vé!'
                  : 'Còn ${maxCapacity - attendees} vé',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: percentage > 80 ? Colors.red : AppTheme.textGrey,
                fontWeight: percentage > 80 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
        child: ElevatedButton(
          onPressed: _addToTrip,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                'Thêm vào lịch trình',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang chia sẻ sự kiện...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _addToTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm sự kiện vào lịch trình!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

