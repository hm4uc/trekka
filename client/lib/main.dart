import 'package:flutter/material.dart';
import 'app.dart'; // Import widget gốc TrekkaApp
import 'injection_container.dart' as di; // Import Dependency Injection

void main() async {
  // 1. Đảm bảo Flutter Binding được khởi tạo trước khi làm bất cứ thứ gì
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Dependency Injection (Các Service, Repository, Bloc...)
  await di.init();

  // 3. Chạy ứng dụng
  runApp(const TrekkaApp());
}