import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../reviews/presentation/bloc/review_bloc.dart';
import '../../../reviews/presentation/bloc/review_event.dart';
import '../../../reviews/presentation/bloc/review_state.dart';
import '../../../reviews/domain/entities/review.dart' as ReviewEntity;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DestinationReviewsPage extends StatefulWidget {
  final Destination destination;

  const DestinationReviewsPage({super.key, required this.destination});

  @override
  State<DestinationReviewsPage> createState() => _DestinationReviewsPageState();
}

class _DestinationReviewsPageState extends State<DestinationReviewsPage> {
  String _selectedFilter = 'recent'; // recent, rating_high, rating_low, helpful
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    context.read<ReviewBloc>().add(GetDestinationReviewsEvent(
          destId: widget.destination.id,
          page: _currentPage,
          limit: _pageSize,
          sortBy: _selectedFilter,
        ));
  }

  void _changeFilter(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
      _currentPage = 1;
    });
    _loadReviews();
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
          'reviews'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, reviewState) {
          final authState = context.watch<AuthBloc>().state;
          final currentUserId = authState is AuthSuccess ? authState.user.id : null;

          return Column(
            children: [
              // Rating Summary - pass reviews data
              if (reviewState is ReviewsLoaded)
                _buildRatingSummary(reviewState.reviews)
              else
                _buildRatingSummary([]),

              // Filter Chips
              _buildFilterChips(),

              // Reviews List
              Expanded(
                child: _buildReviewsList(reviewState, currentUserId),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewsList(ReviewState state, String? currentUserId) {
    if (state is ReviewLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (state is ReviewError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'error'.tr(),
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
              onPressed: _loadReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: Text('try_again'.tr()),
            ),
          ],
        ),
      );
    }

    if (state is ReviewsLoaded) {
      if (state.reviews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rate_review_outlined,
                  size: 64, color: AppTheme.textGrey),
              const SizedBox(height: 16),
              Text(
                'no_reviews'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        itemCount: state.reviews.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildReviewCard(state.reviews[index], currentUserId);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRatingSummary(List<ReviewEntity.Review> reviews) {
    // Calculate rating distribution
    final ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        ratingCounts[review.rating] = (ratingCounts[review.rating] ?? 0) + 1;
      }
    }

    final totalReviews = reviews.length;
    final overallRating = totalReviews > 0
        ? reviews.fold<double>(0, (sum, review) => sum + review.rating) / totalReviews
        : widget.destination.rating;

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
                overallRating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < overallRating.floor() ? Icons.star : Icons.star_border,
                    color: AppTheme.primaryColor,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${totalReviews > 0 ? totalReviews : widget.destination.totalReviews} ${"reviews".tr()}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Rating bars with actual data
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = ratingCounts[star] ?? 0;
                final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

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
                      SizedBox(
                        width: 40,
                        child: Text(
                          totalReviews > 0 ? '${(percentage * 100).toInt()}%' : '0%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                          ),
                          textAlign: TextAlign.right,
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
          _buildFilterChip('recent'.tr(), 'recent'),
          const SizedBox(width: 8),
          _buildFilterChip('highest_rated'.tr(), 'rating_high'),
          const SizedBox(width: 8),
          _buildFilterChip('lowest_rated'.tr(), 'rating_low'),
          const SizedBox(width: 8),
          _buildFilterChip('most_helpful'.tr(), 'helpful'),
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
      onSelected: (_) => _changeFilter(value),
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      showCheckmark: false,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.white10,
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity.Review review, String? currentUserId) {
    final reviewUser = review.user;
    final isOwnReview = currentUserId != null && review.userId == currentUserId;

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
                backgroundImage: reviewUser?.avatar != null
                    ? NetworkImage(reviewUser!.avatar!)
                    : null,
                backgroundColor: AppTheme.primaryColor,
                child: reviewUser?.avatar == null
                    ? Text(
                        reviewUser?.fullname.isNotEmpty == true
                            ? reviewUser!.fullname[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewUser?.fullname ?? 'Anonymous',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Sentiment badge
              if (review.sentiment.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSentimentColor(review.sentiment).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    review.sentiment.toLowerCase().tr(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getSentimentColor(review.sentiment),
                    ),
                  ),
                ),
              // Edit/Delete buttons for own review
              if (isOwnReview) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                  color: AppTheme.surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditReviewDialog(review);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(review);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'edit'.tr(),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            'delete'.tr(),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // ...existing code for stars, comment, images, actions...
          const SizedBox(height: 12),

          // Stars
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                size: 18,
                color: AppTheme.primaryColor,
              );
            }),
          ),
          const SizedBox(height: 12),

          // Comment
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),

          // Images
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(review.images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions (helpful count)
          Row(
            children: [
              if (review.isVerifiedVisit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'verified_visit'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: Mark as helpful API call
                },
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text(
                  '${"helpful".tr()} (${review.helpfulCount})',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} ${"weeks_ago".tr()}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${"days_ago".tr()}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${"hours_ago".tr()}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${"minutes_ago".tr()}';
    } else {
      return 'just_now'.tr();
    }
  }

  void _showEditReviewDialog(ReviewEntity.Review review) {
    final ratingController = ValueNotifier<int>(review.rating);
    final commentController = TextEditingController(text: review.comment);
    final scaffoldContext = context; // Store context

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ReviewBloc>(),
        child: BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is ReviewUpdated) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('review_updated_successfully'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
              _loadReviews(); // Reload reviews
            } else if (state is ReviewError) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: Text(
              'edit_review'.tr(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'rating'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<int>(
                    valueListenable: ratingController,
                    builder: (context, rating, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () {
                              ratingController.value = index + 1;
                            },
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'comment'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'please_enter_review'.tr(),
                      hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'cancel'.tr(),
                  style: GoogleFonts.inter(color: AppTheme.textGrey),
                ),
              ),
              BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, state) {
                  final isLoading = state is ReviewLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (commentController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                SnackBar(
                                  content: Text('please_enter_review'.tr()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            context.read<ReviewBloc>().add(UpdateReviewEvent(
                                  id: review.id,
                                  rating: ratingController.value,
                                  comment: commentController.text.trim(),
                                  images: review.images,
                                ));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text('update'.tr()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ReviewEntity.Review review) {
    final scaffoldContext = context; // Store context

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ReviewBloc>(),
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'delete_review'.tr(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            'delete_review_confirmation'.tr(),
            style: GoogleFonts.inter(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.inter(color: AppTheme.textGrey),
              ),
            ),
            BlocConsumer<ReviewBloc, ReviewState>(
              listener: (context, state) {
                if (state is ReviewDeleted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text('review_deleted_successfully'.tr()),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadReviews(); // Reload reviews
                } else if (state is ReviewError) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is ReviewLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<ReviewBloc>().add(DeleteReviewEvent(review.id));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('delete'.tr()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
