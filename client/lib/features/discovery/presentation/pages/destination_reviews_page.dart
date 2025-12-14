import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';

class DestinationReviewsPage extends StatefulWidget {
  final Destination destination;

  const DestinationReviewsPage({super.key, required this.destination});

  @override
  State<DestinationReviewsPage> createState() => _DestinationReviewsPageState();
}

class _DestinationReviewsPageState extends State<DestinationReviewsPage> {
  String _selectedFilter = 'all'; // all, 5star, 4star, 3star, positive, negative

  // Mock review data (replace with actual API data)
  final List<Review> _mockReviews = [
    Review(
      id: '1',
      userName: 'An Nguyen',
      userAvatar: null,
      rating: 5,
      date: DateTime.now().subtract(const Duration(days: 2)),
      comment: 'Cảnh đẹp thật sự xuất sắc! Không khí trong lành, phù hợp để đi vào cuối tuần. Tuy phải đi qua một đoạn đường đất nhưng rất đáng để trải nghiệm. Chắc chắn sẽ quay lại!',
      likes: 32,
      images: [],
    ),
    Review(
      id: '2',
      userName: 'Bình Tran',
      userAvatar: null,
      rating: 4,
      date: DateTime.now().subtract(const Duration(days: 5)),
      comment: 'Đẹp nhưng giá hơi đắt một chút. Overall thì vẫn rất ổn để đi một lần. Nên đến vào mùa thu sẽ đẹp hơn.',
      likes: 15,
      images: [],
    ),
    Review(
      id: '3',
      userName: 'Chi Vo',
      userAvatar: null,
      rating: 5,
      date: DateTime.now().subtract(const Duration(days: 10)),
      comment: 'Tuyệt vời! Rất đáng để khám phá. Nhân viên thân thiện, hỗ trợ nhiệt tình. Sẽ giới thiệu cho bạn bè.',
      likes: 28,
      images: [],
    ),
  ];

  List<Review> get _filteredReviews {
    if (_selectedFilter == 'all') return _mockReviews;
    if (_selectedFilter == '5star') {
      return _mockReviews.where((r) => r.rating == 5).toList();
    }
    if (_selectedFilter == '4star') {
      return _mockReviews.where((r) => r.rating == 4).toList();
    }
    if (_selectedFilter == '3star') {
      return _mockReviews.where((r) => r.rating == 3).toList();
    }
    if (_selectedFilter == 'positive') {
      return _mockReviews.where((r) => r.rating >= 4).toList();
    }
    if (_selectedFilter == 'negative') {
      return _mockReviews.where((r) => r.rating <= 2).toList();
    }
    return _mockReviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh giá',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Rating Summary
          _buildRatingSummary(),

          // Filter Chips
          _buildFilterChips(),

          // Reviews List
          Expanded(
            child: _filteredReviews.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: _filteredReviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(_filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteReviewDialog(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.edit),
        label: Text(
          'Viết đánh giá',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Large rating number
          Column(
            children: [
              Text(
                widget.destination.rating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.destination.rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: AppTheme.primaryColor,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.destination.totalReviews} đánh giá',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Rating bars
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                // Mock percentage
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tất cả', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('5 sao', '5star'),
          const SizedBox(width: 8),
          _buildFilterChip('4 sao', '4star'),
          const SizedBox(width: 8),
          _buildFilterChip('3 sao', '3star'),
          const SizedBox(width: 8),
          _buildFilterChip('Tích cực', 'positive'),
          const SizedBox(width: 8),
          _buildFilterChip('Tiêu cực', 'negative'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      showCheckmark: false,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.white10,
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                child: review.userAvatar != null
                    ? null
                    : Text(
                        review.userName[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatDate(review.date),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: AppTheme.primaryColor,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 16, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      'Hữu ích (${review.likes})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {},
                child: Text(
                  'Trả lời',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rate_review_outlined, size: 64, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá nào',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showWriteReviewDialog(),
            child: Text(
              'Hãy là người đầu tiên đánh giá!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} phút trước';
      }
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inDays < 30) {
      return '${diff.inDays ~/ 7} tuần trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sắp xếp theo',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('Mới nhất', Icons.access_time),
              _buildFilterOption('Hữu ích nhất', Icons.thumb_up),
              _buildFilterOption('Đánh giá cao nhất', Icons.star),
              _buildFilterOption('Đánh giá thấp nhất', Icons.star_border),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        label,
        style: GoogleFonts.inter(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Viết đánh giá',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Comment field
              TextField(
                controller: commentController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn...',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
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
                // Submit review
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn đã đánh giá!'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: Text(
                'Gửi',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Review model
class Review {
  final String id;
  final String userName;
  final String? userAvatar;
  final int rating;
  final DateTime date;
  final String comment;
  final int likes;
  final List<String> images;

  Review({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
    required this.likes,
    required this.images,
  });
}

