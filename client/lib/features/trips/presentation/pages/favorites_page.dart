import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/locale_keys.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import '../../../destinations/presentation/bloc/destination_state.dart';
import '../../../discovery/presentation/widgets/destination_card.dart';

class FavoritesPage extends StatefulWidget {
  final int initialTab;

  const FavoritesPage({super.key, this.initialTab = 0});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTypeFilter; // 'destination' or 'event' or null (all)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Fetch data when tab changes
        if (_tabController.index == 0) {
          // Liked tab - refresh data
          context.read<DestinationBloc>().add(const GetLikedItemsEvent(limit: 20));
        } else {
          // Checked-in tab - refresh data
          context.read<DestinationBloc>().add(const GetCheckedInItemsEvent(limit: 20));
        }
      }
    });
    // Fetch initial data based on initialTab
    if (widget.initialTab == 0) {
      context.read<DestinationBloc>().add(const GetLikedItemsEvent(limit: 20));
    } else {
      context.read<DestinationBloc>().add(const GetCheckedInItemsEvent(limit: 20));
    }
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

          // Filter Chips
          _buildFilterChips(),

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
          LocaleKeys.favoritesTitle.tr(),
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
          tabs: [
            Tab(text: LocaleKeys.liked.tr()),
            Tab(text: LocaleKeys.checkedIn.tr()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip(
              label: LocaleKeys.allItems.tr(),
              value: null,
              isSelected: _selectedTypeFilter == null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: LocaleKeys.destinations.tr(),
              value: 'destination',
              isSelected: _selectedTypeFilter == 'destination',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: LocaleKeys.events.tr(),
              value: 'event',
              isSelected: _selectedTypeFilter == 'event',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTypeFilter = selected ? value : null;
        });
        // Refresh data with filter
        if (_tabController.index == 0) {
          context.read<DestinationBloc>().add(
                GetLikedItemsEvent(limit: 20, type: _selectedTypeFilter),
              );
        } else {
          context.read<DestinationBloc>().add(
                GetCheckedInItemsEvent(limit: 20, type: _selectedTypeFilter),
              );
        }
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.white10,
      ),
    );
  }

  Widget _buildLikedTab() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is LikedItemsLoading) {
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DestinationBloc>().add(
                          const GetLikedItemsEvent(limit: 20),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(LocaleKeys.tryAgain.tr(), style: const TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        }

        if (state is LikedItemsLoaded) {
          if (state.items.isEmpty) {
            return _buildEmptyState(
              icon: Icons.favorite_border,
              title: LocaleKeys.noFavoriteDestinations.tr(),
              subtitle: LocaleKeys.startExploring.tr(),
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
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final destination = state.items[index];
              return DestinationCard(destination: destination);
            },
          );
        }

        return _buildEmptyState(
          icon: Icons.favorite_border,
          title: LocaleKeys.noFavoriteDestinations.tr(),
          subtitle: LocaleKeys.startExploring.tr(),
        );
      },
    );
  }

  Widget _buildCheckedInTab() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is CheckedInItemsLoading) {
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DestinationBloc>().add(
                          const GetCheckedInItemsEvent(limit: 20),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(LocaleKeys.tryAgain.tr(), style: const TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        }

        if (state is CheckedInItemsLoaded) {
          if (state.items.isEmpty) {
            return _buildEmptyState(
              icon: Icons.location_on_outlined,
              title: LocaleKeys.noVisitedDestinations.tr(),
              subtitle: LocaleKeys.checkInToDestinations.tr(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final destination = state.items[index];
              return _buildCheckedInCard(destination);
            },
          );
        }

        return _buildEmptyState(
          icon: Icons.location_on_outlined,
          title: LocaleKeys.noVisitedDestinations.tr(),
          subtitle: LocaleKeys.checkInToDestinations.tr(),
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
                                '${destination.totalCheckins} ${LocaleKeys.times.tr()}',
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
            textAlign: TextAlign.center,
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
              LocaleKeys.exploreNow.tr(),
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

