import 'package:trekka/core/error/exceptions.dart';
import 'package:trekka/features/auth/data/models/user_model.dart';
import 'package:trekka/core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String usrFullname,
    required String usrEmail,
    required String password,
    String? usrGender,
    int? usrAge,
    String? usrJob,
    List<String>? usrPreferences,
    double? usrBudget,
  });
  Future<UserModel> getProfile(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post('/auth/login', data: {
      'usr_email': email,
      'password': password,
    });
    return UserModel.fromJson(response['data']['profile']);
  }

  @override
  Future<UserModel> register({
    required String usrFullname,
    required String usrEmail,
    required String password,
    String? usrGender,
    int? usrAge,
    String? usrJob,
    List<String>? usrPreferences,
    double? usrBudget,
  }) async {
    final response = await client.post('/auth/register', data: {
      'usr_fullname': usrFullname,
      'usr_email': usrEmail,
      'password': password,
      'usr_gender': usrGender,
      'usr_age': usrAge,
      'usr_job': usrJob,
      'usr_preferences': usrPreferences,
      'usr_budget': usrBudget,
    });
    return UserModel.fromJson(response['data']['profile']);
  }

  @override
  Future<UserModel> getProfile(String token) async {
    // Client cần được cấu hình với token
    final response = await client.get('/auth/profile');
    return UserModel.fromJson(response['data']);
  }
}