import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Cần thêm intl vào pubspec.yaml để format tiền
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';

// 1. Mock Data (Giả lập dữ liệu từ API bạn cung cấp)
final List<Map<String, String>> TRAVEL_STYLES = [
  {"id": "nature", "label": "Thiên nhiên & Cảnh quan", "icon": "mountain"},
  {"id": "culture_history", "label": "Văn hóa & Lịch sử", "icon": "temple"},
  {"id": "food_drink", "label": "Ẩm thực & Cafe", "icon": "utensils"},
  {"id": "chill_relax", "label": "Chill & Thư giãn", "icon": "umbrella-beach"},
  {"id": "adventure", "label": "Mạo hiểm & Thể thao", "icon": "hiking"},
  {"id": "shopping_entertainment", "label": "Mua sắm & Giải trí", "icon": "shopping-bag"},
  {"id": "luxury", "label": "Sang trọng", "icon": "gem"},
  {"id": "local_life", "label": "Đời sống bản địa", "icon": "home"},
];

const BUDGET_CONFIG = {
  "MIN": 0.0,
  "MAX": 50000000.0,
  "STEP": 100000.0,
  "DEFAULT": 1000000.0,
};

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  int _currentStep = 1; // 1: Sở thích, 2: Ngân sách
  final Set<String> _selectedStyles = {}; // Lưu các ID đã chọn
  double _currentBudget = (BUDGET_CONFIG["DEFAULT"] as double);

  // Map icon string -> IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'mountain': return Icons.landscape_outlined;
      case 'temple': return Icons.temple_buddhist_outlined;
      case 'utensils': return Icons.restaurant_menu_outlined;
      case 'umbrella-beach': return Icons.beach_access_outlined;
      case 'hiking': return Icons.hiking_outlined;
      case 'shopping-bag': return Icons.shopping_bag_outlined;
      case 'gem': return Icons.diamond_outlined;
      case 'home': return Icons.home_work_outlined;
      default: return Icons.category_outlined;
    }
  }

  // Helper format tiền tệ (VD: 1,000,000 đ)
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _onContinue() {
    if (_currentStep == 1) {
      if (_selectedStyles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn ít nhất 1 sở thích!")),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      // Step 2: Hoàn tất -> Submit API -> Chuyển sang Location Permission
      // TODO: Call API update profile here
      if (kDebugMode) {
        print("Selected: $_selectedStyles, Budget: $_currentBudget");
      }
      context.go('/location-permission');
    }
  }

  void _onBack() {
    if (_currentStep == 2) {
      setState(() => _currentStep = 1);
    } else {
      // Nếu muốn cho phép back về login thì dùng context.pop()
      // Nhưng thường luồng này nên chặn back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == 2
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: _onBack,
        )
            : null,
        title: Text(
          "Bước $_currentStep/2",
          style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textGrey),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/location-permission'), // Nút Bỏ qua
            child: Text("Bỏ qua", style: GoogleFonts.inter(color: AppTheme.primaryColor)),
          )
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                Expanded(child: _buildProgressIndicator(active: _currentStep >= 1)),
                const SizedBox(width: 8),
                Expanded(child: _buildProgressIndicator(active: _currentStep >= 2)),
              ],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 1 ? _buildStep1Interests() : _buildStep2Budget(),
            ),
          ),

          // Bottom Button Area
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: PrimaryButton(
              text: _currentStep == 1 ? "Tiếp tục" : "Hoàn tất",
              onPressed: _onContinue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryColor : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // --- STEP 1: CHỌN SỞ THÍCH ---
  Widget _buildStep1Interests() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Sở thích du lịch\ncủa bạn là gì?",
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy chọn ít nhất một mục để Trekka cá nhân hóa gợi ý cho bạn.",
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cột
              childAspectRatio: 1.1, // Tỷ lệ khung hình (Card hơi vuông)
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: TRAVEL_STYLES.length,
            itemBuilder: (context, index) {
              final item = TRAVEL_STYLES[index];
              final isSelected = _selectedStyles.contains(item['id']);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedStyles.remove(item['id']);
                    } else {
                      _selectedStyles.add(item['id']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                    // Nếu bạn có ảnh thật, dùng DecorationImage ở đây
                    // image: DecorationImage(image: AssetImage('assets/images/${item['id']}.jpg'), fit: BoxFit.cover),
                  ),
                  child: Stack(
                    children: [
                      // Icon & Text
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon container
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconData(item['icon']!),
                                color: isSelected ? AppTheme.primaryColor : Colors.white,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item['label']!,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Checkmark badge
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 12, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100), // Khoảng trống dưới cùng
        ],
      ),
    );
  }

  // --- STEP 2: CHỌN NGÂN SÁCH ---
  Widget _buildStep2Budget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Tùy chỉnh chuyến đi\ncủa bạn",
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Ngân sách dự kiến cho mỗi chuyến đi giúp chúng tôi gợi ý các dịch vụ phù hợp.",
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 60),

          // Hiển thị số tiền to
          Center(
            child: Column(
              children: [
                Text(
                  "Ngân sách dự kiến",
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatCurrency(_currentBudget),
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.surfaceColor,
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
              valueIndicatorTextStyle: const TextStyle(color: Colors.black),
            ),
            child: Slider(
              value: _currentBudget,
              min: BUDGET_CONFIG["MIN"] as double,
              max: BUDGET_CONFIG["MAX"] as double,
              divisions: ((BUDGET_CONFIG["MAX"] as double) / (BUDGET_CONFIG["STEP"] as double)).round(),
              label: _formatCurrency(_currentBudget),
              onChanged: (value) {
                setState(() {
                  _currentBudget = value;
                });
              },
            ),
          ),

          // Min - Max Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tiết kiệm", style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 12)),
                Text("Thoải mái", style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),

          const Spacer(),
          // Có thể thêm phần chọn "Travel Pace" (Nhanh/Chậm) ở đây nếu muốn giống ảnh mẫu 100%
          const Spacer(),
        ],
      ),
    );
  }
}