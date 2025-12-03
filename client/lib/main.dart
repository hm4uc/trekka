import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/presentation/bloc/preferences_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Khởi tạo Dependency Injection (đợi nó load xong SharedPreferences, v.v.)
  await di.init();

  runApp(
    // 2. Cung cấp AuthBloc cho toàn bộ ứng dụng
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<PreferencesBloc>(create: (context) => di.sl<PreferencesBloc>()),
      ],
      child: const TrekkaApp(),
    ),
  );
}