import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/presentation/bloc/preferences_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize date formatting for Vietnamese locale
  await initializeDateFormatting('vi_VN', null);

  // Initialize Dependency Injection
  await di.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi', 'VN'),
      startLocale: const Locale('vi', 'VN'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
          BlocProvider<PreferencesBloc>(create: (context) => di.sl<PreferencesBloc>()),
        ],
        child: const TrekkaApp(),
      ),
    ),
  );
}