import 'dart:ui'; // Cần import để dùng ImageFilter
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_themes.dart';

class TrekkaBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TrekkaBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Tạo khoảng cách để bar "nổi" lên
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Bo tròn hình viên thuốc
        child: BackdropFilter(
          // Hiệu ứng làm mờ nền phía sau (Glassmorphism)
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70, // Chiều cao thanh bar
            decoration: BoxDecoration(
              // Màu nền bán trong suốt (Đen mờ)
              color: const Color(0xFF1E1E2C).withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.1), // Viền sáng nhẹ tạo khối
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, "home".tr()),
                _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, "explore".tr()),
                _buildNavItem(2, Icons.map_rounded, Icons.map_outlined, "journey".tr()),
                _buildNavItem(3, Icons.favorite_rounded, Icons.favorite_border_rounded, "favorites".tr()),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, "profile".tr()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // Để bấm được cả vùng trống
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // Khi chọn thì hiện nền màu xanh nhạt, không chọn thì trong suốt
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon có Animation
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0, // Phóng to nhẹ khi chọn
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textGrey,
                size: 26,
              ),
            ),

            // Dấu chấm tròn nhỏ bên dưới (Indicator) thay vì hiện Text
            // Giúp giao diện sạch (Clean) hơn
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: isSelected ? 4 : 0, // Chỉ hiện khi chọn
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}