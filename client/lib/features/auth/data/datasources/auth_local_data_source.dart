import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // Chỉ cần 1 key duy nhất để lưu toàn bộ User Object
  static const CACHED_USER_DATA = 'CACHED_USER_DATA';

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await sharedPreferences.setString(CACHED_USER_DATA, jsonString);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_DATA);
    if (jsonString == null) return null;

    try {
      // Đọc chuỗi JSON và parse ngược lại thành UserModel
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(CACHED_USER_DATA);
  }

  @override
  Future<String?> getToken() async {
    final user = await getLastUser();
    return user?.token;
  }
}