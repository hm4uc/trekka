// lib/features/auth/presentation/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Biến kiểm tra xem đã gửi mail chưa để đổi giao diện
  bool _isEmailSent = false;

  void _handleResetPassword() {
    // TODO: Gọi API gửi mail reset password tại đây
    // Giả lập gửi thành công sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isEmailSent = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Để nút Back đè lên ảnh nền
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(), // Quay lại màn Login
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ảnh nền (Giống AuthPage)
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Overlay
          Positioned.fill(
            child: Container(
              color: AppTheme.backgroundColor.withOpacity(0.85),
            ),
          ),

          // 3. Nội dung chính
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _isEmailSent
                  ? _buildSuccessView()
                  : _buildRequestView(),
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện nhập Email
  Widget _buildRequestView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          "Quên mật khẩu?",
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Đừng lo lắng! Hãy nhập email đã đăng ký của bạn, chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu.",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),

        const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const AuthTextField(
          hintText: "Nhập email của bạn",
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 30),
        PrimaryButton(
          text: "Gửi yêu cầu",
          onPressed: _handleResetPassword,
        ),
      ],
    );
  }

  // Giao diện khi đã gửi thành công
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Đã gửi email!",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Vui lòng kiểm tra hộp thư đến của bạn và làm theo hướng dẫn để đặt lại mật khẩu.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          text: "Quay lại đăng nhập",
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}