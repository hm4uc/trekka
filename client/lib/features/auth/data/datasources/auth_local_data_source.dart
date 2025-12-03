import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // Key hằng số để tránh gõ sai
  static const CACHED_TOKEN = 'CACHED_TOKEN';
  static const CACHED_USER_ID = 'CACHED_USER_ID';
  static const CACHED_USER_NAME = 'CACHED_USER_NAME';
  static const CACHED_USER_EMAIL = 'CACHED_USER_EMAIL';

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(CACHED_TOKEN, user.token ?? '');
    await sharedPreferences.setInt(CACHED_USER_ID, user.id);
    await sharedPreferences.setString(CACHED_USER_NAME, user.fullname);
    await sharedPreferences.setString(CACHED_USER_EMAIL, user.email);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final token = sharedPreferences.getString(CACHED_TOKEN);
    // Nếu không có token nghĩa là chưa đăng nhập
    if (token == null || token.isEmpty) return null;

    final id = sharedPreferences.getInt(CACHED_USER_ID) ?? 0;
    final name = sharedPreferences.getString(CACHED_USER_NAME) ?? '';
    final email = sharedPreferences.getString(CACHED_USER_EMAIL) ?? '';

    return UserModel(
      id: id,
      fullname: name,
      email: email,
      token: token,
    );
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.clear();
  }
}