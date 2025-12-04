import '../../../../core/network/api_client.dart';
import '../../domain/usecases/update_profile.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String fullname, String email, String password);
  Future<UserModel> getProfile(String token);
  Future<void> logout(String token);
  Future<void> logoutAllDevices(String token);
  Future<UserModel> updateProfile(String token, UpdateProfileParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', data: {
      "usr_email": email,
      "password": password,
    });
    // response ở đây là Map<String, dynamic> do ApiClient trả về
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> register(String fullname, String email, String password) async {
    final response = await apiClient.post('/auth/register', data: {
      "usr_fullname": fullname,
      "usr_email": email,
      "password": password,
      // "usr_gender": "",
      // "usr_age": 0, // Gửi 0
    });
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> getProfile(String token) async {
    // Cập nhật Header cho Dio trước khi gọi
    apiClient.dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await apiClient.get('/user/profile');
    // Response: { "status": "success", "data": { ... } }
    return UserModel.fromJson(response);
  }

  @override
  Future<void> logout(String token) async {
    apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
    // API trả về 200 OK nếu thành công
    await apiClient.post('/auth/logout');
  }

  @override
  Future<void> logoutAllDevices(String token) async {
    apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
    await apiClient.post('/auth/logout-all-devices');
  }

  @override
  Future<UserModel> updateProfile(String token, UpdateProfileParams params) async {
    apiClient.dio.options.headers['Authorization'] = 'Bearer $token';

    // Gọi PUT /user/profile
    final response = await apiClient.put('/user/profile', data: params.toJson());

    return UserModel.fromJson(response);
  }
}