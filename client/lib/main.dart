import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Khởi tạo Dependency Injection (đợi nó load xong SharedPreferences, v.v.)
  await di.init();

  runApp(
    // 2. Cung cấp AuthBloc cho toàn bộ ứng dụng
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(), // Lấy Bloc từ GetIt
        ),
      ],
      child: const TrekkaApp(),
    ),
  );
}