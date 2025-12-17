import '../../../../core/network/api_client.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? eventType,
    double? lat,
    double? lng,
    double radius = 5000,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  });

  Future<List<EventModel>> getUpcomingEvents({
    double? lat,
    double? lng,
    double radius = 5000,
    int limit = 10,
  });

  Future<EventModel> getEventById(String id);
  Future<Map<String, dynamic>> likeEvent(String id);
  Future<EventModel> checkinEvent(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient apiClient;

  EventRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? eventType,
    double? lat,
    double? lng,
    double radius = 5000,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'radius': radius,
    };

    if (search != null) queryParams['search'] = search;
    if (eventType != null) queryParams['eventType'] = eventType;
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
    }
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    final response = await apiClient.get('/events', queryParameters: queryParams);
    return response;
  }

  @override
  Future<List<EventModel>> getUpcomingEvents({
    double? lat,
    double? lng,
    double radius = 5000,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'radius': radius,
      'limit': limit,
    };

    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;

    final response = await apiClient.get(
      '/events/upcoming',
      queryParameters: queryParams,
    );
    final List<dynamic> data = response['data'];
    return data.map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  Future<EventModel> getEventById(String id) async {
    final response = await apiClient.get('/events/$id');
    return EventModel.fromJson(response['data']);
  }

  @override
  Future<Map<String, dynamic>> likeEvent(String id) async {
    final response = await apiClient.post('/events/$id/like');
    return response;
  }

  @override
  Future<EventModel> checkinEvent(String id) async {
    final response = await apiClient.post('/events/$id/checkin');
    return EventModel.fromJson(response['data']);
  }
}

