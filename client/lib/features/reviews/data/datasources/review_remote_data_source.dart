import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<Map<String, dynamic>> createReview({
    String? destId,
    String? eventId,
    required int rating,
    required String comment,
    List<String>? images,
  });

  Future<Map<String, dynamic>> getDestinationReviews({
    required String destId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  });

  Future<Map<String, dynamic>> getEventReviews({
    required String eventId,
    int page = 1,
    int limit = 10,
  });

  Future<Map<String, dynamic>> getMyReviews({
    int page = 1,
    int limit = 10,
  });

  Future<ReviewModel> updateReview({
    required String id,
    int? rating,
    String? comment,
    List<String>? images,
  });

  Future<void> deleteReview(String id);

  Future<Map<String, dynamic>> markReviewHelpful(String id);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> createReview({
    String? destId,
    String? eventId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    final data = <String, dynamic>{
      'rating': rating,
      'comment': comment,
      'images': images ?? [],
    };

    if (destId != null) {
      data['destId'] = destId;
    } else if (eventId != null) {
      data['eventId'] = eventId;
    }

    final response = await apiClient.post('/reviews', data: data);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getDestinationReviews({
    required String destId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  }) async {
    final response = await apiClient.get(
      '/reviews/destinations/$destId',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
      },
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getEventReviews({
    required String eventId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/reviews/events/$eventId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getMyReviews({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/reviews/my-reviews',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response;
  }

  @override
  Future<ReviewModel> updateReview({
    required String id,
    int? rating,
    String? comment,
    List<String>? images,
  }) async {
    final data = <String, dynamic>{};
    if (rating != null) data['rating'] = rating;
    if (comment != null) data['comment'] = comment;
    if (images != null) data['images'] = images;

    final response = await apiClient.put('/reviews/$id', data: data);
    return ReviewModel.fromJson(response['data']);
  }

  @override
  Future<void> deleteReview(String id) async {
    await apiClient.dio.delete('/reviews/$id');
  }

  @override
  Future<Map<String, dynamic>> markReviewHelpful(String id) async {
    final response = await apiClient.post('/reviews/$id/helpful');
    return response;
  }
}

