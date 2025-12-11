import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/events_near_you_widget.dart';
import '../widgets/home_dummy_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Ngưỡng scroll để chuyển đổi giao diện (khoảng 140px)
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Khi cuộn quá 140px (gần hết phần expanded), chuyển sang chế độ collapsed
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 140 && !_isCollapsed) {
        setState(() => _isCollapsed = true);
      } else if (_scrollController.offset <= 140 && _isCollapsed) {
        setState(() => _isCollapsed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final displayName = authState is AuthSuccess
              ? authState.user.fullname.split(' ').last // Lấy tên (Last name) cho thân mật
              : 'Bạn';

          // Avatar url hoặc ảnh mặc định
          final avatarUrl = (authState is AuthSuccess &&
                  authState.user.avatar != null &&
                  authState.user.avatar!.startsWith('http'))
              ? authState.user.avatar
              : null;

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. APP BAR (COLLAPSIBLE HEADER)
              _buildSliverAppBar(context, displayName, avatarUrl),

              // 2. HERO SLIDER (AI SUGGESTION)
              _buildSectionTitle("Dành riêng cho bạn ✦"),
              _buildHeroSlider(),

              // 3. YOUTH CATEGORIES
              _buildSectionTitle("Hôm nay đi đâu?"),
              _buildQuickCategories(),

              // 4. EVENTS NEAR YOU
              _buildSectionTitle("Sự kiện gần bạn 🎉"),
              _buildEventsSection(),

              // 5. TRENDING
              _buildSectionTitle("Xu hướng tuần này 🔥"),
              _buildHorizontalList(HomeMockData.trending, isLarge: false),

              // 6. BUDGET CHALLENGE
              _buildSectionTitle("Thử thách ngân sách 💸"),
              _buildBudgetGrid(),

              // 7. FOODTOUR
              _buildSectionTitle("Foodtour không lối về 🍜"),
              _buildHorizontalList(HomeMockData.food, isCircle: true),

              // 8. SHORTS
              _buildSectionTitle("Trekka Shorts 🎬"),
              _buildShortsList(),

              // PADDING BOTTOM (Để không bị BottomBar che)
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  // --- SLIVER APP BAR ---

  Widget _buildSliverAppBar(BuildContext context, String displayName, String? avatarUrl) {
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundColor,
      surfaceTintColor: AppTheme.backgroundColor,
      // Tránh đổi màu khi scroll
      floating: false,
      pinned: true,
      elevation: 0,
      expandedHeight: 200,
      // Chiều cao khi mở rộng
      collapsedHeight: 70,
      // Chiều cao khi thu gọn

      // Nút hành động (Notification, Settings)
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _isCollapsed ? Colors.transparent : Colors.black12, // Nền mờ khi mở rộng
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: _isCollapsed ? Colors.transparent : Colors.black12,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
            onPressed: () => context.push('/settings'),
          ),
        ),
      ],

      // Title khi thu gọn (Compact Header)
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isCollapsed ? 1.0 : 0.0,
        child: _buildCollapsedHeader(displayName, avatarUrl),
      ),
      centerTitle: false,
      titleSpacing: 0,
      // Để title sát lề trái

      // Flexible Space (Expanded Header)
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 60), // Tránh status bar
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isCollapsed ? 0.0 : 1.0,
            child: _buildExpandedHeader(displayName, avatarUrl),
          ),
        ),
        collapseMode: CollapseMode.pin, // Giữ background cố định khi cuộn
      ),
    );
  }

  // --- HEADER WIDGETS ---

  // Giao diện MỞ RỘNG (Chào + Thời tiết chi tiết)
  Widget _buildExpandedHeader(String displayName, String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Row
          Row(
            children: [
              _buildAvatar(avatarUrl, 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Chào $displayName 👋",
                      style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Hôm nay bạn muốn đi đâu?",
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weather Card (Glassmorphism Style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.surfaceColor.withOpacity(0.8),
                ],
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 36),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("24°C",
                            style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("Hà Nội • Nắng đẹp",
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("AQI 45 (Tốt)",
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện THU GỌN (Compact Header khi cuộn lên)
  Widget _buildCollapsedHeader(String displayName, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildAvatar(avatarUrl, 18),
          const SizedBox(width: 10),

          // Name & Greeting Compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Chào $displayName",
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),

          // Weather Compact (Icon + Temp)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 14),
                const SizedBox(width: 6),
                Text("24°C",
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, double radius) {
    ImageProvider img = (url != null)
        ? NetworkImage(url)
        : const AssetImage('assets/images/welcome.jpg') as ImageProvider;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.surfaceColor,
      backgroundImage: img,
    );
  }

  // --- CÁC WIDGET SECTION KHÁC (Giữ nguyên logic của bạn, chỉ chỉnh UI nhẹ) ---

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            // Icon arrow thay vì text "Xem tất cả" để clean hơn
            const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

  // Hero Slider
  Widget _buildHeroSlider() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200, // Giảm chiều cao chút cho cân đối
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.88),
          padEnds: false, // Căn trái
          itemCount: HomeMockData.aiRecommendations.length,
          itemBuilder: (context, index) {
            final item = HomeMockData.aiRecommendations[index];
            return Container(
              margin: const EdgeInsets.only(left: 20), // Margin trái thay vì phải
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: AssetImage(item.imageUrl), fit: BoxFit.cover),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(6)),
                          child: Text("AI Gợi ý",
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        const SizedBox(height: 6),
                        Text(item.title,
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(item.subtitle,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Quick Categories
  Widget _buildQuickCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: HomeMockData.categories.length,
          itemBuilder: (context, index) {
            final cat = HomeMockData.categories[index];
            return Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3E), // Màu nền tối nhẹ
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Center(child: Text(cat['icon'], style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(height: 8),
                  Text(cat['label'],
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<Place> items, {bool isLarge = false, bool isCircle = false}) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: isCircle ? 140 : 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            if (isCircle) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(radius: 40, backgroundImage: AssetImage(item.imageUrl)),
                    const SizedBox(height: 8),
                    Text(item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              );
            }
            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(item.imageUrl, fit: BoxFit.cover),
                          if (item.tag != null)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(item.tag!,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textGrey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    final mockEvents = [
      Event(
          title: "Food Festival 2025",
          date: "15-17 Dec",
          location: "Hoàng Hoa Thám",
          imageUrl: "assets/images/welcome.jpg",
          category: "Ẩm thực"),
      Event(
          title: "Chợ đêm phố cổ",
          date: "T7-CN",
          location: "Hoàn Kiếm",
          imageUrl: "assets/images/welcome.jpg",
          category: "Văn hóa"),
    ];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver:
          SliverList(delegate: SliverChildListDelegate([EventsNearYouWidget(events: mockEvents)])),
    );
  }

  Widget _buildBudgetGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = HomeMockData.budget[index];
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(image: AssetImage(item.imageUrl), fit: BoxFit.cover)),
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.price,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryColor)),
                        Text(item.title,
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          childCount: HomeMockData.budget.length,
        ),
      ),
    );
  }

  Widget _buildShortsList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.surfaceColor,
                border: Border.all(color: Colors.white10),
                image: const DecorationImage(
                    image: AssetImage('assets/images/welcome.jpg'), fit: BoxFit.cover),
              ),
              child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 32)),
            );
          },
        ),
      ),
    );
  }
}
