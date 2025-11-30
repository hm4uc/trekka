import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_themes.dart';

class TrekkaApp extends StatelessWidget {
  const TrekkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trekka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}