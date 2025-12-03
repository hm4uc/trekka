import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../bloc/auth_bloc.dart'; // Import Bloc

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
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp"), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthRegisterSubmitted(
      _nameController.text.trim(),
      _registerEmailController.text.trim(),
      _registerPasswordController.text,
    ));
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
          context.go('/preferences');
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background & Overlay (Giữ nguyên)
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
                    Center(child: Text("Trekka", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                    const SizedBox(height: 8),
                    Center(child: Text("Hành trình của bạn, theo cách của bạn.", style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 14))),
                    const SizedBox(height: 40),

                    // TabBar (Giữ nguyên)
                    Container(
                      height: 50,
                      decoration: BoxDecoration(color: AppTheme.surfaceColor.withOpacity(0.5), borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(4),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textGrey,
                        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                        tabs: const [Tab(text: "Đăng nhập"), Tab(text: "Đăng ký")],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 👇 THAY ĐỔI Ở ĐÂY:
                    // Dùng BlocBuilder để kiểm tra state, nhưng KHÔNG return Loading Widget
                    // Mà truyền trạng thái loading vào hàm build form
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        // Kiểm tra xem có đang loading không
                        final bool isLoading = state is AuthLoading;

                        return AnimatedCrossFade(
                          // Truyền isLoading vào 2 hàm này
                          firstChild: _buildLoginForm(isLoading),
                          secondChild: _buildRegisterForm(isLoading),
                          crossFadeState: _isLogin ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    // ... (Phần Social Login và Skip giữ nguyên)
                  ],
                ),
              ),
            ),

            // (Tùy chọn) Thêm lớp phủ trong suốt để chặn click lung tung khi đang loading
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

  // 👇 Cập nhật hàm nhận tham số bool isLoading
  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(controller: _emailController, hintText: "Nhập email", keyboardType: TextInputType.emailAddress),

        const SizedBox(height: 20),
        const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _passwordController,
          hintText: "Mật khẩu",
          obscureText: _obscureLoginPass,
          suffixIcon: IconButton(
            icon: Icon(_obscureLoginPass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textGrey),
            onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text("Quên mật khẩu?", style: TextStyle(color: AppTheme.primaryColor))),
        ),
        const SizedBox(height: 20),

        // 👇 Truyền isLoading vào PrimaryButton
        PrimaryButton(
          text: "Đăng nhập",
          isLoading: isLoading, // Loading quay tại nút
          onPressed: _onLoginPressed,
        ),
      ],
    );
  }

  // 👇 Cập nhật hàm nhận tham số bool isLoading
  Widget _buildRegisterForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Họ tên", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(controller: _nameController, hintText: "Họ và tên"),

        const SizedBox(height: 20),
        const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(controller: _registerEmailController, hintText: "Email", keyboardType: TextInputType.emailAddress),

        const SizedBox(height: 20),
        const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _registerPasswordController,
          hintText: "Mật khẩu (>6 ký tự)",
          obscureText: _obscureRegisterPass,
          suffixIcon: IconButton(
            icon: Icon(_obscureRegisterPass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textGrey),
            onPressed: () => setState(() => _obscureRegisterPass = !_obscureRegisterPass),
          ),
        ),

        const SizedBox(height: 20),
        const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _registerConfirmPassController,
          hintText: "Nhập lại mật khẩu",
          obscureText: _obscureRegisterConfirmPass,
          suffixIcon: IconButton(
            icon: Icon(_obscureRegisterConfirmPass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textGrey),
            onPressed: () => setState(() => _obscureRegisterConfirmPass = !_obscureRegisterConfirmPass),
          ),
        ),

        const SizedBox(height: 30),

        // 👇 Truyền isLoading vào PrimaryButton
        PrimaryButton(
          text: "Đăng ký",
          isLoading: isLoading, // Loading quay tại nút
          onPressed: _onRegisterPressed,
        ),
      ],
    );
  }
}