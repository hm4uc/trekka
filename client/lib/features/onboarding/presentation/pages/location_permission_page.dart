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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Ảnh minh họa
              Center(
                child: Image.asset(
                  'assets/images/location_permission_illustration.png', // Nhớ thay bằng ảnh thật của bạn
                  height: 250, // Điều chỉnh kích thước cho phù hợp
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder nếu chưa có ảnh
                    return Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.map_outlined, size: 100, color: AppTheme.primaryColor),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Tiêu đề
              Text(
                "Để Trekka tìm đường\ncho bạn",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Mô tả
              Text(
                "Trekka cần truy cập vị trí của bạn để gửi những gợi ý địa điểm hấp dẫn ngay gần bạn và xây dựng lịch trình phù hợp nhất. Chúng tôi cam kết bảo mật thông tin của bạn.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textGrey,
                  height: 1.5,
                ),
              ),
              const Spacer(),

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
      ),
    );
  }
}