import '../../../../core/network/api_client.dart';
import '../models/destination_model.dart';

abstract class DestinationRemoteDataSource {
  Future<Map<String, dynamic>> getDestinations({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? lat,
    double? lng,
    double radius = 5000,
    bool? isOpenNow,
    String? context,
    String sortBy = 'distance',
    bool? hiddenGemsOnly,
  });

  Future<DestinationModel> getDestinationById(String id);
  Future<List<DestinationModel>> getNearbyDestinations(String id,
      {int limit = 5, double radius = 2000});
  Future<Map<String, dynamic>> likeDestination(String id);
  Future<Map<String, dynamic>> saveDestination(String id);
  Future<Map<String, dynamic>> checkinDestination(String id);
  Future<List<DestinationCategoryModel>> getCategories();
  Future<List<DestinationCategoryModel>> getCategoriesByTravelStyle(
      String travelStyle);
}

class DestinationRemoteDataSourceImpl implements DestinationRemoteDataSource {
  final ApiClient apiClient;

  DestinationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> getDestinations({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? lat,
    double? lng,
    double radius = 5000,
    bool? isOpenNow,
    String? context,
    String sortBy = 'distance',
    bool? hiddenGemsOnly,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'radius': radius,
      'sortBy': sortBy,
    };

    if (search != null) queryParams['search'] = search;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (isOpenNow != null) queryParams['isOpenNow'] = isOpenNow;
    if (context != null) queryParams['context'] = context;
    if (hiddenGemsOnly != null) queryParams['hiddenGemsOnly'] = hiddenGemsOnly;

    final response = await apiClient.get('/destinations', queryParameters: queryParams);
    return response;
  }

  @override
  Future<DestinationModel> getDestinationById(String id) async {
    final response = await apiClient.get('/destinations/$id');
    return DestinationModel.fromJson(response['data']);
  }

  @override
  Future<List<DestinationModel>> getNearbyDestinations(
    String id, {
    int limit = 5,
    double radius = 2000,
  }) async {
    final response = await apiClient.get(
      '/destinations/$id/nearby',
      queryParameters: {'limit': limit, 'radius': radius},
    );
    final List<dynamic> data = response['data'];
    return data.map((json) => DestinationModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> likeDestination(String id) async {
    final response = await apiClient.post('/destinations/$id/like');
    return response;
  }

  @override
  Future<Map<String, dynamic>> saveDestination(String id) async {
    final response = await apiClient.post('/destinations/$id/save');
    return response;
  }

  @override
  Future<Map<String, dynamic>> checkinDestination(String id) async {
    final response = await apiClient.post('/destinations/$id/checkin');
    return response;
  }

  @override
  Future<List<DestinationCategoryModel>> getCategories() async {
    final response = await apiClient.get('/destinations/categories');
    final List<dynamic> data = response['data'];
    return data.map((json) => DestinationCategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<DestinationCategoryModel>> getCategoriesByTravelStyle(
      String travelStyle) async {
    final response = await apiClient.get('/destinations/categories/$travelStyle');
    final List<dynamic> data = response['data'];
    return data.map((json) => DestinationCategoryModel.fromJson(json)).toList();
  }
}

