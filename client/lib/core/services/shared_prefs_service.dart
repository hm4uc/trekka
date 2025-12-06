import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _hasCompletedOnboardingKey = 'hasCompletedOnboarding';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static late SharedPreferences _prefs;

  // Kiểm tra lần đầu mở app
  static bool get isFirstTime {
    return _prefs.getBool(_isFirstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeCompleted() async {
    await _prefs.setBool(_isFirstTimeKey, false);
  }

  // Kiểm tra đã hoàn thành onboarding
  static bool get hasCompletedOnboarding {
    return _prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  // Xóa tất cả dữ liệu (dùng khi logout)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}