import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Remember Me functionality
  static Future<void> saveRememberMeCredentials(String email, String password) async {
    await _preferences?.setString('remembered_email', email);
    await _preferences?.setString('remembered_password', password);
    await _preferences?.setBool('remember_me', true);
  }

  static Future<void> clearRememberMeCredentials() async {
    await _preferences?.remove('remembered_email');
    await _preferences?.remove('remembered_password');
    await _preferences?.setBool('remember_me', false);
  }

  static Future<Map<String, String?>> getRememberedCredentials() async {
    final email = _preferences?.getString('remembered_email');
    final password = _preferences?.getString('remembered_password');
    final rememberMe = _preferences?.getBool('remember_me') ?? false;

    if (rememberMe && email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return {'email': null, 'password': null};
  }

  static Future<bool> isRememberMeEnabled() async {
    return _preferences?.getBool('remember_me') ?? false;
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await _preferences?.setString('auth_token', token);
  }

  static String? getToken() {
    return _preferences?.getString('auth_token');
  }

  static Future<void> clearToken() async {
    await _preferences?.remove('auth_token');
  }
}