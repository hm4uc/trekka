// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Import
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Làm các việc cần thiết (Check token, load config...)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Sau khi xong việc, TẮT màn hình Native Splash đi
    // Lúc này giao diện Flutter bên dưới đã vẽ xong, logo sẽ khớp nhau
    FlutterNativeSplash.remove();

    // 3. Chuyển trang
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giao diện này phải GIỐNG HỆT cấu hình trong flutter_native_splash
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dùng ảnh giống hệt ảnh khai báo trong pubspec.yaml
            // Nếu pubspec dùng PNG thì ở đây cũng nên dùng PNG hoặc SVG kích thước tương đương
            Image.asset(
              'assets/images/trekka_logo_app.png',
              width: 150, // Cần căn chỉnh cho khớp kích thước hiển thị native (tương đối)
            ),
            // Có thể thêm loading spinner bên dưới nếu thích
          ],
        ),
      ),
    );
  }
}