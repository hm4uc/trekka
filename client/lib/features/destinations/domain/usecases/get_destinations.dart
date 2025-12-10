import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/destination_repository.dart';

class GetDestinations {
  final DestinationRepository repository;

  GetDestinations(this.repository);

  Future<Either<Failure, DestinationsResult>> call(GetDestinationsParams params) async {
    return await repository.getDestinations(
      page: params.page,
      limit: params.limit,
      search: params.search,
      categoryId: params.categoryId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      lat: params.lat,
      lng: params.lng,
      radius: params.radius,
      isOpenNow: params.isOpenNow,
      context: params.context,
      sortBy: params.sortBy,
      hiddenGemsOnly: params.hiddenGemsOnly,
    );
  }
}

class GetDestinationsParams {
  final int page;
  final int limit;
  final String? search;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? lat;
  final double? lng;
  final double radius;
  final bool? isOpenNow;
  final String? context;
  final String sortBy;
  final bool? hiddenGemsOnly;

  GetDestinationsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.lat,
    this.lng,
    this.radius = 5000,
    this.isOpenNow,
    this.context,
    this.sortBy = 'distance',
    this.hiddenGemsOnly,
  });
}

