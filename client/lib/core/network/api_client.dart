import 'dart:io';
import 'package:dio/dio.dart';
import 'package:trekka/core/error/exceptions.dart';
import '../constants/constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = const Duration(milliseconds: AppConstants.connectTimeout);
    dio.options.receiveTimeout = const Duration(milliseconds: AppConstants.receiveTimeout);
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Thêm headers để hỗ trợ CORS
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ServerException('Connection timeout', 408);
    } else if (e.type == DioExceptionType.unknown && e.error is SocketException) {
      return ServerException('No Internet connection', 503);
    } else if (e.response != null) {
      return ServerException(
        e.response!.data['message'] ?? 'Server error',
        e.response!.statusCode ?? 500,
      );
    } else {
      return ServerException('Unknown server error', 500);
    }
  }
}