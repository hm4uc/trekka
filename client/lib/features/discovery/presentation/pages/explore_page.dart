import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/locale_keys.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import '../../../destinations/presentation/bloc/destination_state.dart';
import '../widgets/destination_card.dart';

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

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedTravelStyle;
  String _selectedFilter = 'popular'; // popular, nearby, cheap, rating
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refresh data when tab becomes visible (but not on first build)
    if (_hasInitialized) {
      _refreshData();
    } else {
      _hasInitialized = true;
    }
  }

  void _refreshData() {
    context.read<DestinationBloc>().add(GetDestinationsEvent(
          sortBy: _getSortByValue(_selectedFilter) ?? 'rating',
          categoryId: _selectedCategoryId,
          search: _searchController.text.isNotEmpty ? _searchController.text : null,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<DestinationBloc>().state;
      if (state is DestinationLoaded && state.hasMore) {
        context.read<DestinationBloc>().add(
              GetDestinationsEvent(
                page: state.currentPage + 1,
                categoryId: _selectedCategoryId,
                search: _searchController.text.isNotEmpty ? _searchController.text : null,
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
            search: _searchController.text.isNotEmpty ? _searchController.text : null,
            sortBy: _getSortByValue(_selectedFilter) ?? 'rating',
          ),
        );
  }

  void _onTravelStyleSelected(String? travelStyle) {
    setState(() {
      _selectedTravelStyle = travelStyle;
      _selectedCategoryId = null; // Reset category when changing travel style
    });

    if (travelStyle == null) {
      // Load all categories
      context.read<DestinationBloc>().add(GetCategoriesEvent());
    } else {
      // Load categories by travel style
      context.read<DestinationBloc>().add(
            GetCategoriesByTravelStyleEvent(travelStyle),
          );
    }

    // Reload destinations
    context.read<DestinationBloc>().add(
          GetDestinationsEvent(
            search: _searchController.text.isNotEmpty ? _searchController.text : null,
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
            search: _searchController.text.isNotEmpty ? _searchController.text : null,
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Search and Filter Button
          _buildSliverAppBar(),

          // Active Filters (shown when filters are applied)
          _buildActiveFilters(),

          // Destinations Grid
          _buildDestinationsGrid(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    // Count active filters
    int activeFilterCount = 0;
    if (_selectedCategoryId != null) activeFilterCount++;
    if (_selectedTravelStyle != null) activeFilterCount++;
    if (_selectedFilter != 'popular') activeFilterCount++; // popular is default

    return SliverAppBar(
      backgroundColor: AppTheme.backgroundColor,
      floating: true,
      pinned: true,
      elevation: 0,
      expandedHeight: 110,
      title: Text(
        LocaleKeys.exploreTitle.tr(),
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
          child: Row(
            children: [
              // Search Field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _onSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.searchPlaces.tr(),
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
              const SizedBox(width: 12),
              // Filter Button
              Container(
                decoration: BoxDecoration(
                  color: activeFilterCount > 0
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: activeFilterCount > 0 ? AppTheme.primaryColor : Colors.white10,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: _showFilterBottomSheet,
                      icon: Icon(
                        Icons.tune,
                        color: activeFilterCount > 0 ? AppTheme.primaryColor : Colors.white,
                      ),
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Active filters chips below search
  Widget _buildActiveFilters() {
    final hasFilters =
        _selectedCategoryId != null || _selectedTravelStyle != null || _selectedFilter != 'popular';

    if (!hasFilters) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_selectedFilter != 'popular')
              _buildActiveFilterChip(
                _getFilterLabel(_selectedFilter),
                () => _onFilterSelected('popular'),
              ),
            if (_selectedTravelStyle != null)
              _buildActiveFilterChip(
                _getTravelStyleLabel(_selectedTravelStyle!),
                () => _onTravelStyleSelected(null),
              ),
            if (_selectedCategoryId != null)
              BlocBuilder<DestinationBloc, DestinationState>(
                builder: (context, state) {
                  String categoryName = 'category'.tr();
                  if (state is DestinationLoaded || state is DestinationLoadingMore) {
                    final categories = state is DestinationLoaded
                        ? state.categories
                        : (state as DestinationLoadingMore).categories;
                    final category = categories.firstWhere(
                      (c) => c.id == _selectedCategoryId,
                      orElse: () => categories.first,
                    );
                    categoryName = category.name;
                  }
                  return _buildActiveFilterChip(
                    categoryName,
                    () => _onCategorySelected(null),
                  );
                },
              ),
            // Clear all button
            InkWell(
              onTap: _clearAllFilters,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'clear_all'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilter = 'popular';
      _selectedTravelStyle = null;
      _selectedCategoryId = null;
    });
    context.read<DestinationBloc>().add(const GetDestinationsEvent());
    context.read<DestinationBloc>().add(GetCategoriesEvent());
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'nearby':
        return 'nearby'.tr();
      case 'popular':
        return 'popular'.tr();
      case 'cheap':
        return 'budget_friendly'.tr();
      case 'rating':
        return 'top_rated'.tr();
      default:
        return filter;
    }
  }

  String _getTravelStyleLabel(String style) {
    // Map travel style IDs to translation keys
    switch (style) {
      case 'nature':
        return 'nature'.tr();
      case 'food_drink':
        return 'food'.tr();
      case 'culture_history':
        return 'culture'.tr();
      case 'adventure':
        return 'adventure'.tr();
      case 'chill_relax':
        return 'Chill & Thư giãn';
      case 'shopping_entertainment':
        return 'Mua sắm & Giải trí';
      case 'luxury':
        return 'Sang trọng';
      case 'local_life':
        return 'Đời sống bản địa';
      default:
        return style;
    }
  }

  void _showFilterBottomSheet() {
    // Get categories before showing modal to avoid BlocBuilder inside StatefulBuilder
    final currentState = context.read<DestinationBloc>().state;
    final categories = currentState is DestinationLoaded
        ? currentState.categories
        : (currentState is DestinationLoadingMore
            ? (currentState).categories
            : []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _buildFilterBottomSheet(categories),
    );
  }

  Widget _buildFilterBottomSheet(List categories) {
    // Copy current filter values to local variables
    String tempFilter = _selectedFilter;
    String? tempTravelStyle = _selectedTravelStyle;
    String? tempCategoryId = _selectedCategoryId;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    Text(
                      'filters'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempFilter = 'popular';
                          tempTravelStyle = null;
                          tempCategoryId = null;
                        });
                      },
                      child: Text(
                        'reset'.tr(),
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort By Section
                      _buildFilterSection(
                        'sort_by'.tr(),
                        Icons.sort,
                        Column(
                          children: [
                            _buildFilterOption(
                              'nearby'.tr(),
                              Icons.near_me,
                              tempFilter == 'nearby',
                              () => setModalState(() => tempFilter = 'nearby'),
                            ),
                            _buildFilterOption(
                              'popular'.tr(),
                              Icons.trending_up,
                              tempFilter == 'popular',
                              () => setModalState(() => tempFilter = 'popular'),
                            ),
                            _buildFilterOption(
                              'budget_friendly'.tr(),
                              Icons.attach_money,
                              tempFilter == 'cheap',
                              () => setModalState(() => tempFilter = 'cheap'),
                            ),
                            _buildFilterOption(
                              'top_rated'.tr(),
                              Icons.star,
                              tempFilter == 'rating',
                              () => setModalState(() => tempFilter = 'rating'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Travel Style Section
                      _buildFilterSection(
                        'travel_style'.tr(),
                        Icons.explore,
                        Column(
                          children: [
                            _buildFilterOption(
                              'all_styles'.tr(),
                              Icons.public,
                              tempTravelStyle == null,
                              () => setModalState(() => tempTravelStyle = null),
                            ),
                            _buildFilterOption(
                              'nature'.tr(),
                              Icons.park,
                              tempTravelStyle == 'nature',
                              () => setModalState(() => tempTravelStyle = 'nature'),
                            ),
                            _buildFilterOption(
                              'food'.tr(),
                              Icons.restaurant,
                              tempTravelStyle == 'food_drink',
                              () => setModalState(() => tempTravelStyle = 'food_drink'),
                            ),
                            _buildFilterOption(
                              'culture'.tr(),
                              Icons.museum,
                              tempTravelStyle == 'culture_history',
                              () => setModalState(() => tempTravelStyle = 'culture_history'),
                            ),
                            _buildFilterOption(
                              'adventure'.tr(),
                              Icons.hiking,
                              tempTravelStyle == 'adventure',
                              () => setModalState(() => tempTravelStyle = 'adventure'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category Section
                      _buildFilterSection(
                        'category'.tr(),
                        Icons.category,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCategoryChip(
                              'all_categories'.tr(),
                              Icons.apps,
                              tempCategoryId == null,
                              () => setModalState(() => tempCategoryId = null),
                            ),
                            ...categories.map((category) {
                              return _buildCategoryChip(
                                category.name,
                                _getCategoryIcon(category.icon),
                                tempCategoryId == category.id,
                                () => setModalState(() => tempCategoryId = category.id),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Apply Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply the temp values to actual state
                      setState(() {
                        _selectedFilter = tempFilter;
                        _selectedTravelStyle = tempTravelStyle;
                        _selectedCategoryId = tempCategoryId;
                      });
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'apply_filters'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primaryColor.withValues(alpha: 0.15) : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textGrey,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.white,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'museum':
        return Icons.museum;
      case 'park':
        return Icons.park;
      case 'beach':
        return Icons.beach_access;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.place;
    }
  }

  void _applyFilters() {
    // Handle travel style change
    if (_selectedTravelStyle != null) {
      context.read<DestinationBloc>().add(
            GetCategoriesByTravelStyleEvent(_selectedTravelStyle!),
          );
    } else {
      context.read<DestinationBloc>().add(GetCategoriesEvent());
    }

    // Apply filters
    context.read<DestinationBloc>().add(
          GetDestinationsEvent(
            categoryId: _selectedCategoryId,
            search: _searchController.text.isNotEmpty ? _searchController.text : null,
            sortBy: _getSortByValue(_selectedFilter) ?? 'rating',
          ),
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
                  if (state is DestinationLoadingMore && index == destinations.length) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    );
                  }

                  final destination = destinations[index];
                  return DestinationCard(destination: destination);
                },
                childCount:
                    state is DestinationLoadingMore ? destinations.length + 1 : destinations.length,
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
