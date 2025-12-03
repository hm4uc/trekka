import '../../../../core/network/api_client.dart';
import '../models/travel_constants_model.dart';

abstract class PreferencesRemoteDataSource {
  Future<TravelConstantsModel> getTravelConstants();
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final ApiClient apiClient;

  PreferencesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<TravelConstantsModel> getTravelConstants() async {
    // Gọi API: GET /user/travel-constants
    final response = await apiClient.get('/user/travel-constants');

    // Response cấu trúc: { "status": "success", "data": { ... } }
    // ApiClient của bạn trả về response.data (tức là Map JSON root)
    return TravelConstantsModel.fromJson(response['data']);
  }
}