// lib/features/auth/presentation/pages/auth_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLogin = true;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPassController = TextEditingController();

  // State visibility
  bool _obscureLoginPass = true;
  bool _obscureRegisterPass = true;
  bool _obscureRegisterConfirmPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _isLogin = _tabController.index == 0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPassController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---
  void _onLoginPressed() {
    context.read<AuthBloc>().add(AuthLoginSubmitted(
          _emailController.text.trim(),
          _passwordController.text,
        ));
  }

  void _onRegisterPressed() {
    if (_registerPasswordController.text != _registerConfirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('password_mismatch'.tr()), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthRegisterSubmitted(
          _nameController.text.trim(),
          _registerEmailController.text.trim(),
          _registerPasswordController.text,
        ));
  }

  // TODO: Cần thêm Event vào AuthBloc để xử lý 2 hàm này
  void _onGoogleSignInPressed() {
    // context.read<AuthBloc>().add(AuthGoogleSignInRequested());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('google_signin_dev'.tr())));
  }

  void _onAppleSignInPressed() {
    // context.read<AuthBloc>().add(AuthAppleSignInRequested());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('apple_signin_dev'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthSuccess) {
          if (state.isNewUser) {
            // Người dùng mới đăng ký -> Vào chọn sở thích
            context.go('/preferences');
          } else {
            // Người dùng cũ đăng nhập -> Vào thẳng Home
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background & Overlay
            Positioned.fill(
              child: Image.asset('assets/images/auth_background.jpg', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: AppTheme.backgroundColor.withOpacity(0.85)),
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
                                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                    const SizedBox(height: 8),
                    Center(
                        child: Text('your_journey_your_way'.tr().replaceAll('\\n', ' '),
                            style: GoogleFonts.inter(color: AppTheme.primaryColor, fontSize: 14))),
                    const SizedBox(height: 40),

                    // TabBar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(4),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textGrey,
                        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                        tabs: [
                          Tab(text: 'login'.tr()),
                          Tab(text: 'register'.tr()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Main Form (Login/Register)
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final bool isLoading = state is AuthLoading;
                        return AnimatedCrossFade(
                          firstChild: _buildLoginForm(isLoading),
                          secondChild: _buildRegisterForm(isLoading),
                          crossFadeState:
                              _isLogin ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // --- PHẦN SOCIAL LOGIN MỚI THÊM ---
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      // Disable nút khi đang loading
                      final bool isLoading = state is AuthLoading;
                      return Column(
                        children: [
                          _buildDivider(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildSocialButton(
                                iconPath: 'assets/icons/google.png',
                                // Đảm bảo bạn đã có file này
                                label: "Google",
                                onPressed: _onGoogleSignInPressed,
                                isLoading: isLoading,
                              ),
                              const SizedBox(width: 16),
                              _buildSocialButton(
                                iconPath: 'assets/icons/apple.png',
                                // Đảm bảo bạn đã có file này
                                label: "Apple",
                                onPressed: _onAppleSignInPressed,
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 40),
                    // (Tùy chọn: Thêm nút Bỏ qua/Khám phá ngay ở đây nếu muốn)
                  ],
                ),
              ),
            ),

            // Loading Overlay (Optional - nếu muốn chặn toàn màn hình)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return state is AuthLoading
                    ? const ModalBarrier(dismissible: false, color: Colors.transparent)
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS CON CHO SOCIAL LOGIN ---

  // Dòng kẻ phân cách "Hoặc tiếp tục với"
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.textGrey.withOpacity(0.3), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or_continue_with'.tr(),
              style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 13)),
        ),
        Expanded(child: Divider(color: AppTheme.textGrey.withOpacity(0.3), thickness: 1)),
      ],
    );
  }

  // Nút Social được thiết kế riêng
  Widget _buildSocialButton({
    required String iconPath,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: AppTheme.surfaceColor, // Sử dụng màu bề mặt tối
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withOpacity(0.08), // Viền sáng rất nhẹ tạo khối
                  width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dùng Image.asset để hiển thị logo màu gốc
              Image.asset(iconPath, height: 22, width: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC FORM CŨ (Đã cập nhật thêm isLoading cho nút chính) ---

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('email'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
            controller: _emailController,
            hintText: 'enter_email'.tr(),
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        Text('password'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _passwordController,
          hintText: 'enter_password'.tr(),
          obscureText: _obscureLoginPass,
          suffixIcon: IconButton(
            icon: Icon(_obscureLoginPass ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textGrey),
            onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: Text('forgot_password'.tr(),
                  style: const TextStyle(color: AppTheme.primaryColor))),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          text: 'login'.tr(),
          isLoading: isLoading,
          onPressed: _onLoginPressed,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('full_name'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(controller: _nameController, hintText: 'enter_full_name'.tr()),
        const SizedBox(height: 20),
        Text('email'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
            controller: _registerEmailController,
            hintText: 'enter_email'.tr(),
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        Text('password'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _registerPasswordController,
          hintText: 'enter_password_hint'.tr(),
          obscureText: _obscureRegisterPass,
          suffixIcon: IconButton(
            icon: Icon(_obscureRegisterPass ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textGrey),
            onPressed: () => setState(() => _obscureRegisterPass = !_obscureRegisterPass),
          ),
        ),
        const SizedBox(height: 20),
        Text('confirm_password'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _registerConfirmPassController,
          hintText: 're_enter_password'.tr(),
          obscureText: _obscureRegisterConfirmPass,
          suffixIcon: IconButton(
            icon: Icon(_obscureRegisterConfirmPass ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textGrey),
            onPressed: () =>
                setState(() => _obscureRegisterConfirmPass = !_obscureRegisterConfirmPass),
          ),
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: 'register'.tr(),
          isLoading: isLoading,
          onPressed: _onRegisterPressed,
        ),
      ],
    );
  }
}
