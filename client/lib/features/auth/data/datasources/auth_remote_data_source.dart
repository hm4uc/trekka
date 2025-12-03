import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String fullname, String email, String password);
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
      "usr_gender": "", // Gửi rỗng theo yêu cầu
      "usr_age": 0,    // Gửi 0
      "usr_job": ""
    });
    return UserModel.fromJson(response);
  }
}