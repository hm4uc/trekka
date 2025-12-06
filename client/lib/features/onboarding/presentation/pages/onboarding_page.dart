import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../core/theme/app_themes.dart';

// Model dữ liệu
class OnboardingItem {
  final String image;
  final String title;
  final String description;
  final String buttonText;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isNavigating = false;

  // Dữ liệu nội dung
  final List<OnboardingItem> _contents = [
    OnboardingItem(
      image: 'assets/images/welcome.jpg',
      title: 'Hành trình của bạn,\ntheo cách của bạn',
      description: 'Trợ lý du lịch thông minh giúp bạn khám phá điểm đến độc đáo và cá nhân hóa mọi lịch trình.',
      buttonText: 'Tiếp tục',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding_intro_2.jpg',
      title: 'Gợi ý chuẩn xác từ AI',
      description: 'Phân tích sâu sở thích và ngữ cảnh để thiết kế những chuyến đi "độc bản" dành riêng cho bạn.',
      buttonText: 'Tiếp tục',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding_intro_3.jpg',
      title: 'Linh hoạt theo thực tế',
      description: 'Tự động điều chỉnh kế hoạch ngay tức thì theo thay đổi của thời tiết, giao thông và cảm hứng của bạn.',
      buttonText: 'Tiếp tục',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding_intro_4.jpg',
      title: 'Bắt đầu cùng Trekka',
      description: 'Sẵn sàng khởi tạo hành trình mang đậm dấu ấn cá nhân của bạn.',
      buttonText: 'Bắt đầu ngay',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    await SharedPrefsService.init();
  }

  Future<void> _onNextPressed() async {
    if (_isNavigating) return;
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isNavigating = true);
      await _completeOnboarding();
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // 1. Lưu trạng thái đã hoàn thành onboarding
      await SharedPrefsService.setOnboardingCompleted();

      // 2. Chuyển hướng đến trang auth
      if (!mounted) return;
      _goToAuth();

    } catch (e) {
      // Nếu có lỗi, vẫn chuyển đến trang auth để đảm bảo flow không bị chặn
      if (mounted) {
        _goToAuth();
      }
    }
  }

  void _goToAuth() {
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---------------------------------------------
          // LAYER 1: ẢNH NỀN & OVERLAY (PAGEVIEW)
          // ---------------------------------------------
          PageView.builder(
            controller: _pageController,
            itemCount: _contents.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final item = _contents[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh nền
                  Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                  ),
                  // Lớp phủ tối (Gradient Overlay) giúp chữ dễ đọc
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8), // Đậm dần xuống dưới
                          Colors.black.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Logo Trekka (Chỉ hiện ở Tab 1 - Vị trí 30% màn hình)
                  if (index == 0)
                    Positioned(
                      top: size.height * 0.3,
                      left: 0,
                      right: 0,
                      child: Text(
                        "Trekka",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // ---------------------------------------------
          // LAYER 2: PHẦN TEXT (Tiêu đề & Mô tả)
          // Ghim đáy cách màn hình 150px -> Sẽ mọc ngược lên trên
          // ---------------------------------------------
          Positioned(
            bottom: 150, // Vị trí này đảm bảo nằm TRÊN Dots và Button
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao vừa đủ nội dung
              children: [
                // Tiêu đề
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    _contents[_currentPage].title,
                    key: ValueKey('title_$_currentPage'), // Key để tạo hiệu ứng animation
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Mô tả
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    _contents[_currentPage].description,
                    key: ValueKey('desc_$_currentPage'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------
          // LAYER 3: DOTS INDICATOR (CỐ ĐỊNH)
          // Ghim cố định, không nằm trong Column text nên sẽ KHÔNG NHẢY
          // ---------------------------------------------
          Positioned(
            bottom: 115, // Cố định nằm giữa Text và Button
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _contents.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  // Tab đang chọn sẽ dài hơn (24px), tab khác ngắn (6px)
                  width: _currentPage == index ? 24 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

          // ---------------------------------------------
          // LAYER 4: BUTTON (CỐ ĐỊNH)
          // ---------------------------------------------
          Positioned(
            bottom: 40, // Luôn cách đáy 40px
            left: 24,
            right: 24,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.backgroundColor, // Chữ màu tối
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  _contents[_currentPage].buttonText,
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
  }
}