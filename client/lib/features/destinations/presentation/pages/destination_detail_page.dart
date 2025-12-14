import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_themes.dart';
import '../../domain/entities/destination.dart';
// import '../../bloc/destination_bloc.dart';
// import '../../bloc/destination_event.dart';
import '../../../discovery/presentation/pages/destination_reviews_page.dart';

class DestinationDetailPage extends StatefulWidget {
  final String destinationId;
  final Destination? destination;

  const DestinationDetailPage({
    super.key,
    required this.destinationId,
    this.destination,
  });

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  int _currentImageIndex = 0;
  bool _isSaved = false;
  bool _isLiked = false;
  late Map<String, dynamic> _destination;

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      _destination = {
        'id': widget.destination!.id,
        'name': widget.destination!.name,
        'description': widget.destination!.description,
        'address': widget.destination!.address,
        'avgCost': widget.destination!.avgCost ?? 0.0,
        'rating': widget.destination!.rating,
        'totalReviews': widget.destination!.totalReviews,
        'totalLikes': widget.destination!.totalLikes,
        'images': widget.destination!.images.isNotEmpty
            ? widget.destination!.images
            : ['https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800'],
        'openingHours': widget.destination!.openingHours ?? {},
        'aiSummary': widget.destination!.aiSummary ?? 'Chưa có tóm tắt từ AI.',
        'tags': widget.destination!.tags,
        'category': widget.destination!.category?.name ?? 'Địa điểm',
      };
    } else {
      _destination = _mockDestination;
    }
  }

  // Mock data - replace with API call
  final _mockDestination = {
    'id': '1',
    'name': 'The Ylang Coffee - Hồ Gươm',
    'description': 'Quán cafe view hồ đẹp, không gian yên tĩnh phù hợp làm việc và hẹn hò. Đồ uống đa dạng, giá cả hợp lý.',
    'address': '2 Lê Thạch, Hoàn Kiếm, Hà Nội',
    'avgCost': 80000.0,
    'rating': 4.5,
    'totalReviews': 120,
    'totalLikes': 450,
    'images': [
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
    ],
    'openingHours': {
      'monday': '08:00-22:00',
      'tuesday': '08:00-22:00',
      'wednesday': '08:00-22:00',
      'thursday': '08:00-22:00',
      'friday': '08:00-23:00',
      'saturday': '08:00-23:00',
      'sunday': '08:00-22:00',
    },
    'aiSummary': 'Không gian yên tĩnh, phù hợp làm việc và hẹn hò. View hồ đẹp, giá trung bình.',
    'tags': ['wifi', 'view', 'quiet', 'work-friendly'],
    'category': 'Cafe',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildStatusBadge(),
                    const SizedBox(height: 16),
                    _buildAISummary(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 16),
                    _buildInfoSection(),
                    const SizedBox(height: 16),
                    _buildOpeningHours(),
                    const SizedBox(height: 16),
                    _buildReviewsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
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
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() => _isLiked = !_isLiked);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareDestination,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: (_destination['images'] as List?)?.length ?? 0,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                final images = (_destination['images'] as List?) ?? [];
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.surfaceColor,
                      child: const Icon(Icons.image, size: 100, color: Colors.white30),
                    );
                  },
                );
              },
            ),

            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
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

            // Image indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  (_destination['images'] as List?)?.length ?? 0,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? AppTheme.primaryColor
                          : Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _destination['category'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                (_destination['rating'] as double).toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                ' (${_destination['totalReviews']})',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _destination['name'] as String,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _destination['address'] as String,
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

  Widget _buildStatusBadge() {
    final now = DateTime.now();
    final currentDay = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'][now.weekday - 1];
    final hours = (_destination['openingHours'] as Map)[currentDay] as String;
    final parts = hours.split('-');
    final openTime = TimeOfDay(hour: int.parse(parts[0].split(':')[0]), minute: int.parse(parts[0].split(':')[1]));
    final closeTime = TimeOfDay(hour: int.parse(parts[1].split(':')[0]), minute: int.parse(parts[1].split(':')[1]));

    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    String status;
    Color statusColor;
    IconData statusIcon;

    if (nowMinutes >= openMinutes && nowMinutes < closeMinutes) {
      if (closeMinutes - nowMinutes <= 60) {
        status = 'Sắp đóng cửa';
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
      } else {
        status = 'Đang mở cửa';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      }
    } else {
      status = 'Đã đóng cửa';
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 6),
            Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (status == 'Sắp đóng cửa') ...[
              Text(
                ' • Đóng cửa lúc ${parts[1]}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: statusColor.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAISummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.15),
              Colors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Insights',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _destination['aiSummary'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            'Giới thiệu',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _destination['description'] as String,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_destination['tags'] as List).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.attach_money,
            'Chi phí trung bình',
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                .format(_destination['avgCost']),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.favorite,
            'Lượt thích',
            '${_destination['totalLikes']} người yêu thích',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
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

  Widget _buildOpeningHours() {
    final hours = _destination['openingHours'] as Map;
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    final keys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giờ mở cửa',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: List.generate(7, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index < 6 ? 8 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        days[index],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      Text(
                        hours[keys[index]] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to reviews page
                },
                child: Text(
                  'Xem tất cả',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Review preview cards
          _buildReviewPreview(),
        ],
      ),
    );
  }

  Widget _buildReviewPreview() {
    return Container(
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
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: Text(
                  'N',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nguyễn Văn A',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '2 tuần trước',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sentiment_satisfied, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Positive',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Quán cafe đẹp, view hồ tuyệt vời. Đồ uống ngon, giá cả hợp lý. Nhân viên thân thiện.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textGrey,
              height: 1.4,
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
            // Review Button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: IconButton(
                onPressed: () {
                  if (widget.destination != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DestinationReviewsPage(
                          destination: widget.destination!,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.rate_review_outlined, color: Colors.white),
                tooltip: 'Viết đánh giá',
              ),
            ),
            const SizedBox(width: 12),

            // Check-in Button
            Expanded(
              child: OutlinedButton(
                onPressed: _checkIn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Check-in',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Add to Trip Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _addToTrip,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(
                  'Lên lịch',
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

  void _shareDestination() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang chia sẻ địa điểm...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _checkIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Check-in thành công!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Bạn đã check-in tại ${_destination['name']}',
          style: GoogleFonts.inter(color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.inter(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _addToTrip() {
    // TODO: Show Add to Trip modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm vào lịch trình!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

