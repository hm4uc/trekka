import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('CACHED_TOKEN', user.token ?? '');
    await sharedPreferences.setString('CACHED_USER_NAME', user.fullname);
    await sharedPreferences.setInt('CACHED_USER_ID', user.id);
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.clear();
  }
}