import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import './destination_reviews_page.dart';

class DestinationDetailPage extends StatefulWidget {
  final Destination destination;

  const DestinationDetailPage({super.key, required this.destination});

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarCollapsed = false;
  bool _isSaved = false;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isSaved = widget.destination.totalSaves > 0;
    _isLiked = widget.destination.totalLikes > 0;

    _scrollController.addListener(() {
      setState(() {
        _isAppBarCollapsed = _scrollController.hasClients &&
            _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }

  String _formatOpeningHours() {
    final now = DateTime.now();
    final dayOfWeek = _getDayKey(now.weekday);

    if (widget.destination.openingHours != null &&
        widget.destination.openingHours!.containsKey(dayOfWeek)) {
      return widget.destination.openingHours![dayOfWeek]!;
    }
    return 'Không rõ';
  }

  String _getDayKey(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    context.read<DestinationBloc>().add(SaveDestinationEvent(widget.destination.id));
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    context.read<DestinationBloc>().add(LikeDestinationEvent(widget.destination.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsible App Bar with Image
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Actions
                _buildHeader(),

                // Stats (Rating, Reviews, Likes, etc.)
                _buildStats(),

                // Opening Hours & Distance
                _buildQuickInfo(),

                // Description
                _buildDescription(),

                // Location Map Preview
                _buildLocationSection(),

                // Reviews Section
                _buildReviewsSection(),

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
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            widget.destination.images.isNotEmpty
                ? Image.network(
                    widget.destination.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.surfaceColor,
                        child: const Icon(Icons.image, color: AppTheme.textGrey, size: 64),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.surfaceColor,
                    child: const Icon(Icons.image, color: AppTheme.textGrey, size: 64),
                  ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Badges
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  if (widget.destination.isVerified)
                    _buildBadge('Đã xác minh', Icons.verified, AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  if (widget.destination.isHiddenGem)
                    _buildBadge('Hidden Gem', Icons.diamond, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.destination.name,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                onTap: _toggleSave,
                color: _isSaved ? AppTheme.primaryColor : Colors.white,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                onTap: _toggleLike,
                color: _isLiked ? Colors.red : Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.destination.address,
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.star,
            value: widget.destination.rating.toStringAsFixed(1),
            label: '${widget.destination.totalReviews} đánh giá',
            color: AppTheme.primaryColor,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.favorite,
            value: '${widget.destination.totalLikes}',
            label: 'Lượt thích',
            color: Colors.red,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.bookmark,
            value: '${widget.destination.totalSaves}',
            label: 'Đã lưu',
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white10,
    );
  }

  Widget _buildQuickInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Giờ mở cửa',
            value: _formatOpeningHours(),
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          if (widget.destination.avgCost != null)
            _buildInfoRow(
              icon: Icons.attach_money,
              label: 'Chi phí',
              value: '~${_formatPrice(widget.destination.avgCost!)}',
              color: Colors.green,
            ),
          const SizedBox(height: 12),
          if (widget.destination.recommendedDuration != null)
            _buildInfoRow(
              icon: Icons.schedule,
              label: 'Thời gian khám phá',
              value: '${widget.destination.recommendedDuration} phút',
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
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
            'Mô tả',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.destination.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.6,
            ),
          ),
          if (widget.destination.aiSummary != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Đề xuất',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.destination.aiSummary!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.destination.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
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
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Map placeholder (you can integrate Google Maps or other map service)
                  Container(
                    color: AppTheme.surfaceColor,
                    child: const Center(
                      child: Icon(Icons.map, color: AppTheme.textGrey, size: 48),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.destination.address,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Open in maps
                            },
                            child: Text(
                              'Chỉ đường',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationReviewsPage(
                        destination: widget.destination,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.destination.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < widget.destination.rating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppTheme.primaryColor,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.destination.totalReviews} đánh giá',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Rating distribution
                ...List.generate(5, (index) {
                  final star = 5 - index;
                  // Mock percentage (you should calculate this from actual data)
                  final percentage = (star == 5) ? 0.7 : (star == 4) ? 0.2 : 0.05;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 12, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Check-in action
                  context.read<DestinationBloc>().add(
                    CheckinDestinationEvent(widget.destination.id),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Check-in tại ${widget.destination.name} thành công!'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
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
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Check-in',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: IconButton(
                onPressed: () {
                  // Navigate to review page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationReviewsPage(
                        destination: widget.destination,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review, color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

