import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Chào Minh Anh 👋",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                  ],
                ),
              ),

              // 2. Weather Widget
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("28°C Nắng nhẹ",
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        const Text("Hà Nội, Việt Nam",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const Icon(Icons.wb_sunny_outlined,
                        color: AppTheme.primaryColor, size: 32),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Section: Sự kiện (Horizontal Scroll)
              _buildSectionTitle("Sự kiện đang diễn ra gần bạn"),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCard(
                        "Lễ hội âm nhạc", "Hôm nay", Colors.purple.shade900),
                    _buildCard("Chợ phiên cuối tuần", "Thứ 7 - Chủ Nhật",
                        Colors.orange.shade900),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Section: Địa điểm gợi ý (Horizontal Scroll)
              _buildSectionTitle("Địa điểm gợi ý hôm nay"),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildImageCard(
                        "Hồ Hoàn Kiếm", "4.8 • 1.2km", Colors.blue.shade900),
                    _buildImageCard(
                        "Văn Miếu", "4.7 • 2.5km", Colors.brown.shade900),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Section: Cafe (Vertical/Grid)
              _buildSectionTitle("Cafe đẹp gần bạn"),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildImageCard("The Coffee House", "4.5 • 0.5km",
                        Colors.amber.shade900),
                    _buildImageCard(
                        "Cộng Cà Phê", "4.6 • 1.1km", Colors.green.shade900),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Khám phá"),
          BottomNavigationBarItem(
              icon: Icon(Icons.timeline), label: "Lịch trình"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(title,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // Card cho sự kiện (Có nút xem chi tiết)
  Widget _buildCard(String title, String subtitle, Color color) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color, // Placeholder for Image
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text("Xem chi tiết"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card cho địa điểm (Ảnh full)
  Widget _buildImageCard(String title, String rating, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: color, // Placeholder for Image
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.bookmark_border, color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(rating,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
