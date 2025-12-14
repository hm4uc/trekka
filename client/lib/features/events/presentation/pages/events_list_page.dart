import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';
import '../../domain/entities/event.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'all'; // all, happening, upcoming, arts, music

  // Mock event data
  final List<Event> _mockEvents = [
    Event(
      id: '1',
      name: 'Hanoi Art Exhibition 2025',
      description: 'Triển lãm nghệ thuật đương đại với hơn 100 tác phẩm từ các nghệ sĩ nổi tiếng',
      location: 'Tràng Tiền Plaza, Hoàn Kiếm, Hà Nội',
      lat: 21.0245,
      lng: 105.8412,
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(days: 7)),
      ticketPrice: 50000,
      images: ['https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800'],
      category: 'arts',
      isFeatured: true,
      isActive: true,
      totalAttendees: 350,
      organizerName: 'Hanoi Art Center',
    ),
    Event(
      id: '2',
      name: 'Street Food Festival',
      description: 'Lễ hội ẩm thực đường phố với hơn 50 gian hàng từ khắp Hà Nội',
      location: 'Công viên Thống Nhất',
      lat: 21.0134,
      lng: 105.8453,
      startTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 3)),
      ticketPrice: 0,
      images: ['https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800'],
      category: 'food',
      isFeatured: true,
      isActive: true,
      totalAttendees: 1200,
      organizerName: 'Hanoi Tourism',
    ),
    Event(
      id: '3',
      name: 'Live Music Night',
      description: 'Đêm nhạc sống với sự tham gia của nhiều ban nhạc indie nổi tiếng',
      location: 'Hanoi Rock City',
      lat: 21.0187,
      lng: 105.8376,
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      ticketPrice: 150000,
      images: ['https://images.unsplash.com/photo-1511735111819-9a3f7709049c?w=800'],
      category: 'music',
      isFeatured: false,
      isActive: true,
      totalAttendees: 280,
      organizerName: 'Rock City Events',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Event> get _filteredEvents {
    if (_selectedFilter == 'all') return _mockEvents;
    if (_selectedFilter == 'happening') {
      return _mockEvents.where((e) => e.isHappening).toList();
    }
    if (_selectedFilter == 'upcoming') {
      return _mockEvents.where((e) => e.isUpcoming).toList();
    }
    return _mockEvents.where((e) => e.category == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            _buildFilterChips(),
            _buildEventsList(),
          ],
        ),
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
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'id': 'all', 'label': 'Tất cả', 'icon': Icons.apps},
      {'id': 'happening', 'label': 'Đang diễn ra', 'icon': Icons.play_circle},
      {'id': 'upcoming', 'label': 'Sắp diễn ra', 'icon': Icons.upcoming},
      {'id': 'arts', 'label': 'Nghệ thuật', 'icon': Icons.palette},
      {'id': 'music', 'label': 'Âm nhạc', 'icon': Icons.music_note},
      {'id': 'food', 'label': 'Ẩm thực', 'icon': Icons.restaurant},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter['id'];

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.black : AppTheme.textGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter['id'] as String),
              backgroundColor: AppTheme.surfaceColor,
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.black,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.white10,
                width: 1,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 64, color: AppTheme.textGrey),
              const SizedBox(height: 16),
              Text(
                'Không có sự kiện nào',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = _filteredEvents[index];
            return _buildEventCard(event);
          },
          childCount: _filteredEvents.length,
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final dateFormat = DateFormat('dd MMM, HH:mm', 'vi_VN');
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to event detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    event.images.first,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: AppTheme.backgroundColor,
                        child: const Icon(Icons.event, color: AppTheme.textGrey, size: 48),
                      );
                    },
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: event.isHappening
                          ? Colors.red.withOpacity(0.9)
                          : event.isUpcoming
                              ? AppTheme.primaryColor.withOpacity(0.9)
                              : Colors.grey.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          event.isHappening
                              ? Icons.circle
                              : event.isUpcoming
                                  ? Icons.schedule
                                  : Icons.check_circle,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.isHappening
                              ? 'Đang diễn ra'
                              : event.isUpcoming
                                  ? 'Sắp diễn ra'
                                  : 'Đã kết thúc',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Featured Badge
                if (event.isFeatured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            // Event Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  Text(
                    event.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Time
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${dateFormat.format(event.startTime)} - ${dateFormat.format(event.endTime)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Footer: Price and Attendees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          event.ticketPrice != null && event.ticketPrice! > 0
                              ? currencyFormat.format(event.ticketPrice)
                              : 'Miễn phí',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: event.ticketPrice != null && event.ticketPrice! > 0
                                ? AppTheme.primaryColor
                                : Colors.green,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16, color: AppTheme.textGrey),
                          const SizedBox(width: 4),
                          Text(
                            '${event.totalAttendees} người tham gia',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Event Detail Page
class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'vi_VN');
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.surfaceColor,
                        child: const Icon(Icons.event, color: AppTheme.textGrey, size: 64),
                      );
                    },
                  ),
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    Icons.access_time,
                    'Thời gian',
                    '${dateFormat.format(event.startTime)}\n→ ${dateFormat.format(event.endTime)}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.location_on,
                    'Địa điểm',
                    event.location,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.confirmation_number,
                    'Giá vé',
                    event.ticketPrice != null && event.ticketPrice! > 0
                        ? currencyFormat.format(event.ticketPrice)
                        : 'Miễn phí',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.people,
                    'Số người tham gia',
                    '${event.totalAttendees} người',
                  ),
                  const SizedBox(height: 24),
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
                    event.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm sự kiện vào lịch trình!'),
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
            child: Text(
              'Thêm vào hành trình',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
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
                const SizedBox(height: 4),
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
}

