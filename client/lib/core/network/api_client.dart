import 'dart:io';

import 'package:dio/dio.dart';
import 'package:trekka/core/error/exceptions.dart';
import 'package:chuck_interceptor/chuck_interceptor.dart';

import '../constants/constants.dart';

class ApiClient {
  final Dio dio;
  final Chuck chuck;

  ApiClient(this.dio, this.chuck) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = const Duration(milliseconds: AppConstants.connectTimeout);
    dio.options.receiveTimeout = const Duration(milliseconds: AppConstants.receiveTimeout);

    // Thêm headers để hỗ trợ CORS
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Thêm Chuck interceptor - tự động track tất cả HTTP requests
    dio.interceptors.add(chuck.dioInterceptor);

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
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

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await dio.patch(path, data: data);
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

