import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
  Future<String?> getToken();
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
    final tokenToSave = user.token ?? '';

    await sharedPreferences.setString(CACHED_TOKEN, tokenToSave);
    await sharedPreferences.setString(CACHED_USER_ID, user.id.toString());
    await sharedPreferences.setString(CACHED_USER_NAME, user.fullname);
    await sharedPreferences.setString(CACHED_USER_EMAIL, user.email);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final token = sharedPreferences.getString(CACHED_TOKEN);
    if (token == null || token.isEmpty) return null;

    final id = sharedPreferences.getString(CACHED_USER_ID) ?? '';
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
    await sharedPreferences.remove(CACHED_TOKEN);
    await sharedPreferences.remove(CACHED_USER_ID);
    await sharedPreferences.remove(CACHED_USER_NAME);
    await sharedPreferences.remove(CACHED_USER_EMAIL);
  }

  @override
  Future<String?> getToken() async {
    final token = sharedPreferences.getString(CACHED_TOKEN);
    return token;
  }
}