import 'package:equatable/equatable.dart';

abstract class DestinationEvent extends Equatable {
  const DestinationEvent();

  @override
  List<Object?> get props => [];
}

class GetDestinationsEvent extends DestinationEvent {
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
  final bool loadMore;

  const GetDestinationsEvent({
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
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        search,
        categoryId,
        minPrice,
        maxPrice,
        lat,
        lng,
        radius,
        isOpenNow,
        context,
        sortBy,
        hiddenGemsOnly,
        loadMore,
      ];
}

class GetCategoriesEvent extends DestinationEvent {}

class LikeDestinationEvent extends DestinationEvent {
  final String destinationId;

  const LikeDestinationEvent(this.destinationId);

  @override
  List<Object?> get props => [destinationId];
}

class SaveDestinationEvent extends DestinationEvent {
  final String destinationId;

  const SaveDestinationEvent(this.destinationId);

  @override
  List<Object?> get props => [destinationId];
}

class CheckinDestinationEvent extends DestinationEvent {
  final String destinationId;

  const CheckinDestinationEvent(this.destinationId);

  @override
  List<Object?> get props => [destinationId];
}

