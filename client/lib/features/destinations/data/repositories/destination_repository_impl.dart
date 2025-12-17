import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/destination_repository.dart';
import '../datasources/destination_remote_data_source.dart';
import '../models/destination_model.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  final DestinationRemoteDataSource remoteDataSource;

  DestinationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DestinationsResult>> getDestinations({
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
    try {
      final response = await remoteDataSource.getDestinations(
        page: page,
        limit: limit,
        search: search,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lat: lat,
        lng: lng,
        radius: radius,
        isOpenNow: isOpenNow,
        context: context,
        sortBy: sortBy,
        hiddenGemsOnly: hiddenGemsOnly,
      );

      final data = response['data'];
      final destinations = (data['data'] as List)
          .map((json) => DestinationModel.fromJson(json))
          .toList();

      final result = DestinationsResult(
        total: data['total'],
        currentPage: data['currentPage'],
        totalPages: data['totalPages'],
        destinations: destinations,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, Destination>> getDestinationById(String id) async {
    try {
      final destination = await remoteDataSource.getDestinationById(id);
      return Right(destination);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, List<Destination>>> getNearbyDestinations(
    String id, {
    int limit = 5,
    double radius = 2000,
  }) async {
    try {
      final destinations =
          await remoteDataSource.getNearbyDestinations(id, limit: limit, radius: radius);
      return Right(destinations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, int>> likeDestination(String id) async {
    try {
      final response = await remoteDataSource.likeDestination(id);
      return Right(response['data']['total_likes']);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, int>> saveDestination(String id) async {
    try {
      final response = await remoteDataSource.saveDestination(id);
      return Right(response['data']['total_saves']);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, int>> checkinDestination(String id) async {
    try {
      final response = await remoteDataSource.checkinDestination(id);
      return Right(response['data']['total_checkins']);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, List<DestinationCategory>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, List<DestinationCategory>>> getCategoriesByTravelStyle(
      String travelStyle) async {
    try {
      final categories = await remoteDataSource.getCategoriesByTravelStyle(travelStyle);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, UserActivityResult>> getLikedItems({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    try {
      final response = await remoteDataSource.getLikedItems(
        page: page,
        limit: limit,
        type: type,
      );

      final data = response['data'];
      final items = (data['data'] as List)
          .map((json) => DestinationModel.fromJson(json))
          .toList();

      final result = UserActivityResult(
        total: data['total'],
        currentPage: data['currentPage'],
        totalPages: data['totalPages'],
        items: items,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }

  @override
  Future<Either<Failure, UserActivityResult>> getCheckedInItems({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    try {
      final response = await remoteDataSource.getCheckedInItems(
        page: page,
        limit: limit,
        type: type,
      );

      final data = response['data'];
      final items = (data['data'] as List)
          .map((json) => DestinationModel.fromJson(json))
          .toList();

      final result = UserActivityResult(
        total: data['total'],
        currentPage: data['currentPage'],
        totalPages: data['totalPages'],
        items: items,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}', 500));
    }
  }
}
