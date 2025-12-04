import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../widgets/home_dummy_data.dart'; // Import file data vừa tạo

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn nảy kiểu iOS
        slivers: [
          // 1. APP BAR & SEARCH
          _buildSliverAppBar(context),

          // 2. HERO SLIDER (AI SUGGESTION)
          _buildSectionTitle("Dành riêng cho bạn ✦"),
          _buildHeroSlider(),

          // 3. YOUTH CATEGORIES (CAFE, DATING...)
          _buildSectionTitle("Hôm nay đi đâu?"),
          _buildQuickCategories(),

          // 4. TRENDING
          _buildSectionTitle("Xu hướng tuần này 🔥"),
          _buildHorizontalList(HomeMockData.trending, isLarge: false),

          // 5. BUDGET CHALLENGE
          _buildSectionTitle("Thử thách ngân sách 💸"),
          _buildBudgetGrid(),

          // 6. FOODTOUR
          _buildSectionTitle("Foodtour không lối về 🍜"),
          _buildHorizontalList(HomeMockData.food, isCircle: true), // Ảnh tròn cho món ăn

          // 7. SHORTS (VIDEO)
          _buildSectionTitle("Trekka Shorts 🎬"),
          _buildShortsList(),

          // PADDING BOTTOM
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- WIDGETS CON (SLIVERS) ---

  // 1. App Bar
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundColor,
      floating: true,
      pinned: true,
      elevation: 0,
      expandedHeight: 130, // Tăng chiều cao để chứa Search bar

      // 1. TOP BAR: Avatar + Greeting + Icons
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/welcome.jpg'), // Avatar User
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chào Trekker 👋",
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("Sẵn sàng khám phá?",
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to Notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            context.push('/settings'); // Chuyển sang màn Settings
          },
        ),
        const SizedBox(width: 8),
      ],

      // 2. BOTTOM: SEARCH BAR
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          alignment: Alignment.center,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text("Tìm địa điểm, sự kiện...",
                    style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Title
  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Xem tất cả", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  // 2. Hero Slider
  Widget _buildHeroSlider() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9), // Để lộ 1 chút card sau
          itemCount: HomeMockData.aiRecommendations.length,
          itemBuilder: (context, index) {
            final item = HomeMockData.aiRecommendations[index];
            return Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient Overlay
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
                  // Text Content
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
                          child: Text("Gợi ý cho bạn", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        const SizedBox(height: 8),
                        Text(item.title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(item.subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
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

  // 3. Quick Categories (Youth Focus)
  Widget _buildQuickCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
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
                    height: 60, width: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Center(child: Text(cat['icon'], style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(height: 8),
                  Text(cat['label'], style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 4 & 6. Horizontal List (Generic)
  Widget _buildHorizontalList(List<Place> items, {bool isLarge = false, bool isCircle = false}) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: isCircle ? 140 : 200, // Chiều cao tùy chỉnh
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            if (isCircle) {
              // Giao diện tròn cho Food
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(item.imageUrl),
                    ),
                    const SizedBox(height: 8),
                    Text(item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              );
            }
            // Giao diện Card chữ nhật thường
            return Container(
              width: 150,
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
                              top: 8, left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                child: Text(item.tag!, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 5. Budget Grid (SliverGrid)
  Widget _buildBudgetGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4, // Card ngang
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final item = HomeMockData.budget[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: AssetImage(item.imageUrl), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)]),
                    ),
                  ),
                  Positioned(
                    bottom: 12, left: 12, right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.price, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                        Text(item.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // 7. Shorts (Video Dọc)
  Widget _buildShortsList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 250, // Chiều cao lớn cho video dọc
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: 5, // Dummy 5 videos
          itemBuilder: (context, index) {
            return Container(
              width: 140, // Tỷ lệ 9:16 thu nhỏ
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.surfaceColor,
                border: Border.all(color: Colors.white10),
                image: const DecorationImage(
                  // Dùng ảnh tạm, thực tế là video thumbnail
                  image: AssetImage('assets/images/welcome.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40)),
                  Positioned(
                    bottom: 10, left: 10,
                    child: Text("Review Hà Giang\n4N3Đ", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}