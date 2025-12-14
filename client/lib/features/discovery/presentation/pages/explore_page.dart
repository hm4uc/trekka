import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import '../../../destinations/presentation/bloc/destination_state.dart';
import '../widgets/destination_card.dart';
import '../widgets/category_filter_chips.dart';

class ExplorePage extends StatefulWidget {
  final String? initialCategory;
  final String? initialFilter;
  final String? initialSearch;

  const ExplorePage({
    super.key,
    this.initialCategory,
    this.initialFilter,
    this.initialSearch,
  });

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _selectedFilter = 'popular'; // popular, nearby, cheap, rating
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _selectedCategoryId = widget.initialCategory;
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Fetch initial data
    context.read<DestinationBloc>().add(GetDestinationsEvent(
      sortBy: _getSortByValue(_selectedFilter) ?? 'rating',
      categoryId: _selectedCategoryId,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    ));

    // Pagination listener
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<DestinationBloc>().state;
      if (state is DestinationLoaded && state.hasMore) {
        context.read<DestinationBloc>().add(
          GetDestinationsEvent(
            page: state.currentPage + 1,
            categoryId: _selectedCategoryId,
            search: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
            loadMore: true,
          ),
        );
      }
    }
  }

  void _onSearch(String query) {
    context.read<DestinationBloc>().add(
      GetDestinationsEvent(
        search: query.isNotEmpty ? query : null,
        categoryId: _selectedCategoryId,
      ),
    );
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    context.read<DestinationBloc>().add(
      GetDestinationsEvent(
        categoryId: categoryId,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        sortBy: _getSortByValue(_selectedFilter) ?? 'rating',
      ),
    );
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context.read<DestinationBloc>().add(
      GetDestinationsEvent(
        categoryId: _selectedCategoryId,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        sortBy: _getSortByValue(filter) ?? 'rating',
      ),
    );
  }

  String? _getSortByValue(String filter) {
    switch (filter) {
      case 'nearby':
        return 'distance';
      case 'popular':
        return 'rating';
      case 'cheap':
        return 'price';
      default:
        return 'rating';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Search
          _buildSliverAppBar(),

          // Filter Chips (Gần bạn, Phổ biến, Giá rẻ)
          _buildFilterChips(),

          // Category Filters
          _buildCategoryFilters(),

          // Destinations Grid
          _buildDestinationsGrid(),
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
      expandedHeight: 110,
      title: Text(
        "Khám phá",
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Tìm địa điểm, sự kiện...",
              hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textGrey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Text(
              "Tất cả địa điểm",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('Gần bạn', 'nearby', Icons.near_me),
                  const SizedBox(width: 8),
                  _buildFilterChip('Phổ biến', 'popular', Icons.trending_up),
                  const SizedBox(width: 8),
                  _buildFilterChip('Giá rẻ', 'cheap', Icons.attach_money),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đánh giá cao', 'rating', Icons.star),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black : AppTheme.textGrey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => _onFilterSelected(value),
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryColor,
        showCheckmark: false,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.white10,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoaded || state is DestinationLoadingMore) {
          final categories = state is DestinationLoaded
              ? state.categories
              : (state as DestinationLoadingMore).categories;

          return SliverToBoxAdapter(
            child: CategoryFilterChips(
              categories: categories,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: _onCategorySelected,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildDestinationsGrid() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        if (state is DestinationError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.inter(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DestinationBloc>().add(
                        const GetDestinationsEvent(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text("Thử lại", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DestinationLoaded || state is DestinationLoadingMore) {
          final destinations = state is DestinationLoaded
              ? state.destinations
              : (state as DestinationLoadingMore).currentDestinations;

          if (destinations.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.explore_off, color: AppTheme.textGrey, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      "Không tìm thấy địa điểm nào",
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Show loading indicator at the end
                  if (state is DestinationLoadingMore &&
                      index == destinations.length) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    );
                  }

                  final destination = destinations[index];
                  return DestinationCard(destination: destination);
                },
                childCount: state is DestinationLoadingMore
                    ? destinations.length + 1
                    : destinations.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text("Bắt đầu khám phá!", style: TextStyle(color: Colors.white70))),
        );
      },
    );
  }
}

