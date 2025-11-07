// features/auth/data/datasources/auth_remote_data_source.dart
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

    // Handle API response structure
    final userData = response['data'] ?? response;
    final token = response['token'];

    return UserModel.fromJson({
      ...userData['profile'] ?? userData,
      'token': token,
    });
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
    // Create request data with only non-null values
    final Map<String, dynamic> requestData = {
      'usr_fullname': usrFullname,
      'usr_email': usrEmail,
      'password': password,
    };

    // Only add optional fields if they are not null
    if (usrGender != null) requestData['usr_gender'] = usrGender;
    if (usrAge != null) requestData['usr_age'] = usrAge;
    if (usrJob != null) requestData['usr_job'] = usrJob;
    if (usrPreferences != null) requestData['usr_preferences'] = usrPreferences;
    if (usrBudget != null) requestData['usr_budget'] = usrBudget;

    final response = await client.post('/auth/register', data: requestData);

    // Handle API response structure
    final userData = response['data'] ?? response;
    final token = response['token'];

    return UserModel.fromJson({
      ...userData['profile'] ?? userData,
      'token': token,
    });
  }

  @override
  Future<UserModel> getProfile(String token) async {
    // Client cần được cấu hình với token
    final response = await client.get('/auth/profile');
    return UserModel.fromJson(response['data']);
  }
}