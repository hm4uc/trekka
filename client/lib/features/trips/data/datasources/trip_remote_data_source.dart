import '../../../../core/network/api_client.dart';
import '../../domain/entities/trip.dart';
import '../models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<Map<String, dynamic>> getTrips({int page = 1, int limit = 10, String? status});
  Future<Trip> getTripById(String id);
  Future<Trip> createTrip(Map<String, dynamic> tripData);
  Future<Trip> updateTrip(String id, Map<String, dynamic> tripData);
  Future<void> deleteTrip(String id);
  Future<Trip> updateTripStatus(String id, String status);
  Future<Map<String, dynamic>> addDestinationToTrip(String tripId, Map<String, dynamic> destinationData);
  Future<Map<String, dynamic>> addEventToTrip(String tripId, Map<String, dynamic> eventData);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final ApiClient apiClient;

  TripRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getTrips({int page = 1, int limit = 10, String? status}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await apiClient.get('/trips', queryParameters: queryParams);

    // Response format: { "status": "success", "data": { "total": 0, "currentPage": 1, "totalPages": 0, "data": [...] } }
    if (response['status'] == 'success' && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      return {
        'total': data['total'] ?? 0,
        'currentPage': data['currentPage'] ?? 1,
        'totalPages': data['totalPages'] ?? 0,
        'trips': (data['data'] as List?)?.map((e) => TripModel.fromJson(e).toEntity()).toList() ?? [],
      };
    }
    return {'total': 0, 'currentPage': 1, 'totalPages': 0, 'trips': []};
  }

  @override
  Future<Trip> getTripById(String id) async {
    final response = await apiClient.get('/trips/$id');
    return TripModel.fromJson(response).toEntity();
  }

  @override
  Future<Trip> createTrip(Map<String, dynamic> tripData) async {
    final response = await apiClient.post('/trips', data: tripData);
    return TripModel.fromJson(response).toEntity();
  }

  @override
  Future<Trip> updateTrip(String id, Map<String, dynamic> tripData) async {
    final response = await apiClient.put('/trips/$id', data: tripData);
    return TripModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteTrip(String id) async {
    await apiClient.delete('/trips/$id');
  }

  @override
  Future<Trip> updateTripStatus(String id, String status) async {
    final response = await apiClient.patch('/trips/$id/status', data: {'status': status});
    return TripModel.fromJson(response).toEntity();
  }

  @override
  Future<Map<String, dynamic>> addDestinationToTrip(String tripId, Map<String, dynamic> destinationData) async {
    final response = await apiClient.post('/trips/$tripId/destinations', data: destinationData);
    return response;
  }

  @override
  Future<Map<String, dynamic>> addEventToTrip(String tripId, Map<String, dynamic> eventData) async {
    final response = await apiClient.post('/trips/$tripId/events', data: eventData);
    return response;
  }
}
