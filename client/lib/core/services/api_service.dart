import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://trekka-server.onrender.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// 1. ĐĂNG KÝ
  Future<Response> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Các trường không có trong UI (Gender, Age, Job) gửi chuỗi rỗng hoặc 0
      final data = {
        "usr_fullname": fullName.isNotEmpty ? fullName : "",
        "usr_email": email.isNotEmpty ? email : "",
        "password": password,
        "usr_gender": "", // Không có input -> gửi rỗng
        "usr_age": 0,    // Số nguyên -> gửi 0 (API thường không nhận "" cho field int)
        "usr_job": ""     // Không có input -> gửi rỗng
      };

      return await _dio.post('/auth/register', data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// 2. ĐĂNG NHẬP
  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post('/auth/login', data: {
        "usr_email": email,
        "password": password,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 3. LẤY CONSTANTS (Travel Styles & Budget)
  Future<Map<String, dynamic>> getTravelConstants() async {
    try {
      final response = await _dio.get('/user/travel-constants');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      }
      throw Exception("Failed to load constants");
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Lưu Token và User Info
  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user['usr_id'].toString());
    await prefs.setString('user_name', user['usr_fullname'] ?? "");
  }
}