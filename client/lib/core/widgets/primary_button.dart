// lib/core/widgets/primary_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_themes.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading; // Thêm tham số này

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false, // Mặc định là không loading
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, // Chiều cao chuẩn design
      child: ElevatedButton(
        // Khi đang loading thì disable nút (onPressed = null)
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          // Màu khi nút bị disable (loading)
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppTheme.backgroundColor, // Màu tối xoay trên nền xanh
            strokeWidth: 2.5,
          ),
        )
            : Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundColor, // Chữ màu tối
          ),
        ),
      ),
    );
  }
}