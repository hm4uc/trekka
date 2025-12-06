// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/shared_prefs_service.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      // 1. Khởi tạo SharedPreferences
      await SharedPrefsService.init();
      // Giả lập thời gian chờ loading (cho đẹp, optional)
      await Future.delayed(const Duration(seconds: 2));

      // 2. Kiểm tra xem đã hoàn thành Onboarding chưa
      // (Bao gồm cả check isFirstTime, vì nếu completed = true thì chắc chắn không phải first time)
      if (!SharedPrefsService.hasCompletedOnboarding) {
        // ==> Nếu chưa xong Onboarding -> Chuyển hướng sang màn Onboarding
        _removeNativeSplash();
        if (mounted) context.go('/onboarding');
      } else {
        // ==> Nếu đã xong Onboarding -> Kiểm tra trạng thái Đăng nhập
        // Gửi event để Bloc tự check token, gọi API, v.v.
        if (mounted) {
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
        // Lưu ý: Chưa removeNativeSplash ở đây, để BlocListener xử lý tiếp
        // hoặc remove luôn cũng được, tùy trải nghiệm UI
        _removeNativeSplash();
      }
    } catch (e) {
      // Fallback an toàn: Nếu lỗi gì đó, cứ đẩy về Auth
      _removeNativeSplash();
      if (mounted) context.go('/auth');
    }
  }

  void _removeNativeSplash() {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Chỉ lắng nghe khi đã check xong Onboarding (logic ở initState đã đảm bảo điều này)
        if (state is AuthSuccess) {
          // ✅ Token còn hạn, API user/profile trả về 200 OK
          if (mounted) context.go('/home');
        } else if (state is AuthInitial || state is AuthFailure) {
          // ❌ Token hết hạn (401) hoặc không có token -> Về trang đăng nhập
          if (mounted) context.go('/auth');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/trekka_logo_app.png',
                width: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
