import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Trekka",
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Hành trình của bạn, theo cách của bạn.",
                  style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 40),

              // ... (Phần Tabs giữ nguyên hoặc tách ra widget riêng nếu muốn) ...
              // Tạm thời giữ nguyên phần Tabs container để tập trung vào Input/Button

              const SizedBox(height: 30),

              // Inputs dùng Widget mới
              const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const AuthTextField(
                hintText: "Nhập email của bạn",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AuthTextField(
                hintText: "Nhập mật khẩu của bạn",
                obscureText: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility_off, color: AppTheme.textGrey),
                  onPressed: () {},
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Quên mật khẩu?", style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ),

              const SizedBox(height: 20),

              // Primary Button mới
              PrimaryButton(
                text: "Đăng nhập",
                onPressed: () => context.go('/home'),
              ),

              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.surfaceColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Hoặc", style: TextStyle(color: AppTheme.textGrey)),
                  ),
                  Expanded(child: Divider(color: AppTheme.surfaceColor)),
                ],
              ),
              const SizedBox(height: 30),

              // Social Buttons mới
              SocialButton(
                text: "Tiếp tục với Google",
                icon: Icons.g_mobiledata, // Hoặc thay bằng Image.asset
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialButton(
                text: "Tiếp tục với Apple",
                icon: Icons.apple,
                onPressed: () {},
              ),

              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text("Bỏ qua - dùng tạm", style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}