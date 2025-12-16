import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_themes.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/event_card.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final _scrollController = ScrollController();
  String? _selectedEventType;

  final List<Map<String, String>> _eventTypes = [
    {'value': '', 'label': 'Tất cả'},
    {'value': 'festival', 'label': 'Lễ hội'},
    {'value': 'concert', 'label': 'Hòa nhạc'},
    {'value': 'exhibition', 'label': 'Triển lãm'},
    {'value': 'workshop', 'label': 'Workshop'},
    {'value': 'conference', 'label': 'Hội nghị'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<EventBloc>().add(const GetEventsEvent(limit: 20));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<EventBloc>().state;
      if (state is EventLoaded && state.hasMore) {
        context.read<EventBloc>().add(
              GetEventsEvent(
                page: state.currentPage + 1,
                limit: 20,
                eventType: _selectedEventType,
                loadMore: true,
              ),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          _buildSliverAppBar(),

          // Event Type Filter
          _buildEventTypeFilter(),

          // Events List
          _buildEventsList(),
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
          "Sự kiện",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Navigate to search page
          },
        ),
      ],
    );
  }

  Widget _buildEventTypeFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _eventTypes.length,
          itemBuilder: (context, index) {
            final type = _eventTypes[index];
            final isSelected = _selectedEventType == type['value'] ||
                (_selectedEventType == null && type['value'] == '');

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedEventType = type['value'] == '' ? null : type['value'];
                  });
                  context.read<EventBloc>().add(
                        GetEventsEvent(
                          limit: 20,
                          eventType: _selectedEventType,
                        ),
                      );
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return BlocConsumer<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is EventActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is EventLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        if (state is EventError && state is! EventLoaded) {
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<EventBloc>().add(
                            GetEventsEvent(
                              limit: 20,
                              eventType: _selectedEventType,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text(
                      "Thử lại",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is EventLoaded) {
          if (state.events.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_busy,
                        color: AppTheme.primaryColor,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Không tìm thấy sự kiện",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Thử thay đổi bộ lọc để xem\ncác sự kiện khác",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == state.events.length) {
                  // Loading more indicator
                  return state is EventLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }

                final event = state.events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EventCard(
                    event: event,
                    onTap: () {
                      // Navigate to event detail
                    },
                  ),
                );
              },
              childCount: state.events.length + (state.hasMore ? 1 : 0),
            ),
          );
        }

        return const SliverFillRemaining(
          child: SizedBox.shrink(),
        );
      },
    );
  }
}

