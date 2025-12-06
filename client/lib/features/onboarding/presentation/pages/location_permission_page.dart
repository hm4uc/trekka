// lib/features/location/presentation/pages/location_permission_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  Future<void> _requestLocationPermission(BuildContext context) async {
    // TODO: Tích hợp logic xin quyền thực tế ở đây (ví dụ dùng geolocator)
    // Giả lập người dùng đồng ý:
    if (kDebugMode) {
      print("Người dùng đã nhấn 'Cho phép truy cập'");
    }
    // Sau khi có quyền, chuyển đến màn hình Home
    context.go('/home');
  }

  void _skipPermission(BuildContext context) {
    if (kDebugMode) {
      print("Người dùng chọn 'Để sau'");
    }
    // Vẫn chuyển đến Home nhưng có thể bị hạn chế tính năng
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Ảnh minh họa với bo tròn và sát lề
              Container(
                margin: const EdgeInsets.only(bottom: 32.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    width: screenWidth,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Ảnh nền với overlay
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/location_permission_illustration.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Placeholder đẹp hơn nếu chưa có ảnh
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 80,
                                      color: AppTheme.primaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Gradient overlay để làm nổi bật text phía trên
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),

                        // Hiệu ứng bóng mờ viền
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tiêu đề
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      "Để Trekka tìm đường\ncho bạn",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mô tả
                    Text(
                      "Trekka cần truy cập vị trí của bạn để gợi ý những địa điểm thú vị gần bạn và xây dựng lịch trình hoàn hảo nhất. Thông tin của bạn luôn được bảo mật.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textGrey,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Phần nút bấm
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    // Nút "Cho phép truy cập"
                    PrimaryButton(
                      text: "Cho phép truy cập",
                      onPressed: () => _requestLocationPermission(context),
                    ),
                    const SizedBox(height: 16),

                    // Nút "Để sau"
                    TextButton(
                      onPressed: () => _skipPermission(context),
                      child: Text(
                        "Để sau",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}