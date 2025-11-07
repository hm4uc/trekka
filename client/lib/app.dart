import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trekka/config/app_routes.dart';
import 'package:trekka/config/app_themes.dart';
import 'package:trekka/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trekka/features/auth/presentation/screens/login_screen.dart';
import 'package:trekka/features/auth/presentation/screens/register_screen.dart';
import 'package:trekka/features/travel_preferences/presentation/screens/travel_preferences_screen.dart';
import 'package:trekka/presentation/home/home_screen.dart';
import 'package:trekka/presentation/splash/splash_screen.dart';
import 'injection_container.dart' as di;

class TrekkaApp extends StatelessWidget {
  const TrekkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Trekka',
        theme: AppThemes.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.travelPreferences: (context) => const TravelPreferencesScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
        },
      ),
    );
  }
}