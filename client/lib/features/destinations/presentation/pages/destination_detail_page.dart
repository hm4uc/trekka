import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_detail_cubit.dart';
import '../bloc/destination_detail_state.dart';
import '../../../discovery/presentation/pages/destination_reviews_page.dart';

class DestinationDetailPage extends StatelessWidget {
  final String destinationId;
  final Destination? destination;

  const DestinationDetailPage({
    super.key,
    required this.destinationId,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DestinationDetailCubit>()
        ..loadDestinationDetail(destinationId),
      child: _DestinationDetailPageContent(
        destinationId: destinationId,
        initialDestination: destination,
      ),
    );
  }
}

class _DestinationDetailPageContent extends StatefulWidget {
  final String destinationId;
  final Destination? initialDestination;

  const _DestinationDetailPageContent({
    required this.destinationId,
    this.initialDestination,
  });

  @override
  State<_DestinationDetailPageContent> createState() =>
      _DestinationDetailPageContentState();
}

class _DestinationDetailPageContentState
    extends State<_DestinationDetailPageContent> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DestinationDetailCubit, DestinationDetailState>(
      listener: (context, state) {
        if (state is DestinationDetailActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        } else if (state is DestinationDetailActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DestinationDetailLoading) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        if (state is DestinationDetailError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải dữ liệu',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DestinationDetailCubit>()
                          .loadDestinationDetail(widget.destinationId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! DestinationDetailLoaded) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        final destination = state.destination;
        final isLiked = state.isLiked;
        final isSaved = state.isSaved;

        return _buildContent(context, destination, isLiked, isSaved);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    Destination destination,
    bool isLiked,
    bool isSaved,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(destination, isLiked),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(destination),
                    _buildStatusBadge(destination),
                    const SizedBox(height: 16),
                    _buildAISummary(destination),
                    const SizedBox(height: 16),
                    _buildDescription(destination),
                    const SizedBox(height: 16),
                    _buildInfoSection(destination),
                    const SizedBox(height: 16),
                    _buildOpeningHours(destination),
                    const SizedBox(height: 16),
                    _buildReviewsSection(destination),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, destination),
    );
  }

  Widget _buildSliverAppBar(Destination destination, bool isLiked) {
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
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
            ),
            onPressed: () {
              context.read<DestinationDetailCubit>().toggleLike();
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
            onPressed: () => _shareDestination(destination),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: destination.images.isNotEmpty ? destination.images.length : 1,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                final images = destination.images.isNotEmpty
                    ? destination.images
                    : ['https://via.placeholder.com/800x400?text=No+Image'];
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
                      AppTheme.backgroundColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Image indicators
            if (destination.images.isNotEmpty && destination.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    destination.images.length,
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

  Widget _buildHeader(Destination destination) {
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
                  destination.category?.name ?? 'Địa điểm',
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
                destination.rating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                ' (${destination.totalReviews})',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            destination.name,
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
                  destination.address,
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

  Widget _buildStatusBadge(Destination destination) {
    // Check if opening hours exist
    if (destination.openingHours == null || destination.openingHours!.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final currentDay = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][now.weekday - 1];
    final hours = destination.openingHours![currentDay];

    if (hours == null || hours == 'Closed') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Text(
                'Đã đóng cửa',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final parts = hours.split('-');
    if (parts.length != 2) return const SizedBox.shrink();

    try {
      final openParts = parts[0].split(':');
      final closeParts = parts[1].split(':');
      final openTime = TimeOfDay(hour: int.parse(openParts[0]), minute: int.parse(openParts[1]));
      final closeTime = TimeOfDay(hour: int.parse(closeParts[0]), minute: int.parse(closeParts[1]));

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
                    color: statusColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAISummary(Destination destination) {
    if (destination.aiSummary == null || destination.aiSummary!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.15),
              Colors.purple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
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
                    destination.aiSummary!,
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

  Widget _buildDescription(Destination destination) {
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
            destination.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
          if (destination.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: destination.tags.map((tag) {
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
        ],
      ),
    );
  }

  Widget _buildInfoSection(Destination destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (destination.avgCost != null)
            _buildInfoRow(
              Icons.attach_money,
              'Chi phí trung bình',
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                  .format(destination.avgCost),
            ),
          if (destination.avgCost != null) const SizedBox(height: 12),
          _buildInfoRow(
            Icons.favorite,
            'Lượt thích',
            '${destination.totalLikes} người yêu thích',
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
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
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

  Widget _buildOpeningHours(Destination destination) {
    if (destination.openingHours == null || destination.openingHours!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hours = destination.openingHours!;
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    final keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

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
                final dayHours = hours[keys[index]] ?? 'Không có thông tin';
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
                        dayHours,
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

  Widget _buildReviewsSection(Destination destination) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DestinationReviewsPage(
                        destination: destination,
                      ),
                    ),
                  );
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



  Widget _buildBottomBar(BuildContext context, Destination destination) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationReviewsPage(
                        destination: destination,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_outlined, color: Colors.white),
                tooltip: 'Viết đánh giá',
              ),
            ),
            const SizedBox(width: 12),

            // Check-in Button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<DestinationDetailCubit>().performCheckin();
                },
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
                onPressed: () => _addToTrip(destination),
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

  void _shareDestination(Destination destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang chia sẻ ${destination.name}...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _addToTrip(Destination destination) {
    // TODO: Show Add to Trip modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${destination.name} vào lịch trình!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

