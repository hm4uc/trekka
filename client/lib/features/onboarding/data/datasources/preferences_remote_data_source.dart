import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/usecases/update_travel_settings.dart';
import '../models/travel_constants_model.dart';

abstract class PreferencesRemoteDataSource {
  Future<TravelConstantsModel> getTravelConstants();
  Future<void> updateTravelSettings(UpdateTravelSettingsParams params);
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  PreferencesRemoteDataSourceImpl({
    required this.apiClient,
    required this.authLocalDataSource
  });

  @override
  Future<TravelConstantsModel> getTravelConstants() async {
    // Gọi API: GET /user/travel-constants
    final response = await apiClient.get('/user/travel-constants');

    // Response cấu trúc: { "status": "success", "data": { ... } }
    // ApiClient của bạn trả về response.data (tức là Map JSON root)
    return TravelConstantsModel.fromJson(response['data']);
  }

  @override
  Future<void> updateTravelSettings(UpdateTravelSettingsParams params) async {
    final token = await authLocalDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      throw Exception("No token found in local storage");
    }

    await apiClient.post('/user/travel-settings', data: params.toJson());
  }
}