// lib/features/auth/presentation/pages/auth_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLogin = true;

  bool _obscureLoginPass = true;
  bool _obscureRegisterPass = true;
  bool _obscureRegisterConfirmPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _isLogin = _tabController.index == 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToPreferences() {
    context.go('/preferences');
  }

  void _navigateToForgotPassword() {
    context.push('/forgot-password'); // Dùng push để có thể Back về dễ dàng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background & Overlay (Giữ nguyên)
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.backgroundColor.withOpacity(0.85),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Text("Trekka",
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text("Hành trình của bạn, theo cách của bạn.",
                        style: GoogleFonts.inter(
                            color: AppTheme.textGrey, fontSize: 14)),
                  ),
                  const SizedBox(height: 40),

                  // TabBar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textGrey,
                      labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      splashBorderRadius: BorderRadius.circular(25),
                      tabs: const [
                        Tab(text: "Đăng nhập"),
                        Tab(text: "Đăng ký"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  AnimatedCrossFade(
                    firstChild: _buildLoginForm(),
                    secondChild: _buildRegisterForm(),
                    crossFadeState: _isLogin
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),

                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.surfaceColor)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Hoặc",
                            style: TextStyle(color: AppTheme.textGrey)),
                      ),
                      Expanded(child: Divider(color: AppTheme.surfaceColor)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SocialButton(
                    text: "Tiếp tục với Google",
                    icon: Icons.g_mobiledata,
                    onPressed: _navigateToPreferences,
                  ),
                  const SizedBox(height: 16),
                  SocialButton(
                    text: "Tiếp tục với Apple",
                    icon: Icons.apple,
                    onPressed: _navigateToPreferences,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: _navigateToPreferences,
                      child: const Text("Bỏ qua",
                          style: TextStyle(color: AppTheme.primaryColor)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const AuthTextField(
          hintText: "Nhập email của bạn",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // 👇 Cập nhật TextField Password
        AuthTextField(
          hintText: "Nhập mật khẩu của bạn",
          obscureText: _obscureLoginPass, // Dùng biến state
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPass ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textGrey,
            ),
            onPressed: () {
              setState(() {
                _obscureLoginPass = !_obscureLoginPass;
              });
            },
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _navigateToForgotPassword, // 👇 Gọi hàm điều hướng
            child: const Text("Quên mật khẩu?",
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: "Đăng nhập",
          onPressed: _navigateToPreferences,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Họ và tên", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const AuthTextField(hintText: "Nhập họ và tên của bạn"),
        const SizedBox(height: 20),
        const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const AuthTextField(
          hintText: "Nhập email của bạn",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // 👇 Password Đăng ký
        const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          hintText: "Nhập mật khẩu (tối thiểu 6 ký tự)",
          obscureText: _obscureRegisterPass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegisterPass ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textGrey,
            ),
            onPressed: () => setState(() => _obscureRegisterPass = !_obscureRegisterPass),
          ),
        ),

        const SizedBox(height: 20),

        // 👇 Confirm Password Đăng ký
        const Text("Xác nhận mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          hintText: "Nhập lại mật khẩu",
          obscureText: _obscureRegisterConfirmPass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegisterConfirmPass ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textGrey,
            ),
            onPressed: () => setState(() => _obscureRegisterConfirmPass = !_obscureRegisterConfirmPass),
          ),
        ),

        const SizedBox(height: 30),
        PrimaryButton(
          text: "Đăng ký",
          onPressed: _navigateToPreferences,
        ),
      ],
    );
  }
}