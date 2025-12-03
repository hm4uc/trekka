import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart' show FlutterNativeSplash;
import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 👇 Giữ màn hình Splash Native đứng yên đó, không cho tắt tự động
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await di.init();

  runApp(const TrekkaApp());
}