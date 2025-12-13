import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import '../../../destinations/presentation/bloc/destination_state.dart';
import '../../../discovery/presentation/widgets/destination_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Fetch saved destinations
    // For now, we'll use the same destinations endpoint
    // In the future, add a separate API endpoint for saved destinations
    context.read<DestinationBloc>().add(const GetDestinationsEvent(limit: 20));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          _buildSliverAppBar(),

          // Tabs
          _buildTabs(),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLikedTab(),
                _buildCheckedInTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundColor,
      floating: true,
      pinned: true,
      elevation: 0,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Yêu thích",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: "Đã thích"),
            Tab(text: "Đã check-in"),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedTab() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (state is DestinationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        if (state is DestinationLoaded) {
          // Filter destinations that have been liked
          final savedDestinations = state.destinations
              .where((dest) => dest.totalLikes > 0)
              .toList();

          if (savedDestinations.isEmpty) {
            return _buildEmptyState(
              icon: Icons.favorite_border,
              title: "Chưa có địa điểm yêu thích",
              subtitle: "Khám phá và lưu các địa điểm\nbạn yêu thích để xem lại sau",
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: savedDestinations.length,
            itemBuilder: (context, index) {
              final destination = savedDestinations[index];
              return DestinationCard(destination: destination);
            },
          );
        }

        return _buildEmptyState(
          icon: Icons.favorite_border,
          title: "Chưa có địa điểm yêu thích",
          subtitle: "Khám phá và lưu các địa điểm\nbạn yêu thích để xem lại sau",
        );
      },
    );
  }

  Widget _buildCheckedInTab() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (state is DestinationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        if (state is DestinationLoaded) {
          // Filter destinations that have been checked in
          final checkedInDestinations = state.destinations
              .where((dest) => dest.totalCheckins > 0)
              .toList();

          if (checkedInDestinations.isEmpty) {
            return _buildEmptyState(
              icon: Icons.location_on_outlined,
              title: "Chưa check-in địa điểm nào",
              subtitle: "Check-in tại các địa điểm bạn ghé thăm\nđể lưu lại kỷ niệm",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: checkedInDestinations.length,
            itemBuilder: (context, index) {
              final destination = checkedInDestinations[index];
              return _buildCheckedInCard(destination);
            },
          );
        }

        return _buildEmptyState(
          icon: Icons.location_on_outlined,
          title: "Chưa check-in địa điểm nào",
          subtitle: "Check-in tại các địa điểm bạn ghé thăm\nđể lưu lại kỷ niệm",
        );
      },
    );
  }

  Widget _buildCheckedInCard(Destination destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to destination detail
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: destination.images.isNotEmpty
                    ? Image.network(
                        destination.images.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
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
                        width: 80,
                        height: 80,
                        color: AppTheme.backgroundColor,
                        child: const Icon(
                          Icons.place,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.address,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Check-in count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${destination.totalCheckins} lần',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.textGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to explore page
              // You can use context.go('/explore') if using go_router
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.explore, color: Colors.black),
            label: Text(
              "Khám phá ngay",
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

