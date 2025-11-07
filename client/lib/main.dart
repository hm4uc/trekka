import 'package:flutter/material.dart';
import 'package:trekka/app.dart';
import 'core/storage/shared_preferences.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await LocalStorageService.init();
  runApp(const TrekkaApp());
}