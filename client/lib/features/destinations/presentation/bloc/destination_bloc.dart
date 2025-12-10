import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/destination.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_destinations.dart';
import '../../domain/usecases/like_destination.dart';
import '../../domain/usecases/save_destination.dart';
import 'destination_event.dart';
import 'destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final GetDestinations getDestinations;
  final GetCategories getCategories;
  final LikeDestination likeDestination;
  final SaveDestination saveDestination;

  List<DestinationCategory> _categories = [];

  DestinationBloc({
    required this.getDestinations,
    required this.getCategories,
    required this.likeDestination,
    required this.saveDestination,
  }) : super(DestinationInitial()) {
    on<GetDestinationsEvent>(_onGetDestinations);
    on<GetCategoriesEvent>(_onGetCategories);
    on<LikeDestinationEvent>(_onLikeDestination);
    on<SaveDestinationEvent>(_onSaveDestination);
  }

  Future<void> _onGetDestinations(
    GetDestinationsEvent event,
    Emitter<DestinationState> emit,
  ) async {
    // If loading more, show loading state with current data
    if (event.loadMore && state is DestinationLoaded) {
      final currentState = state as DestinationLoaded;
      emit(DestinationLoadingMore(
        currentDestinations: currentState.destinations,
        categories: currentState.categories,
      ));
    } else {
      emit(DestinationLoading());
    }

    // Fetch categories if not loaded yet
    if (_categories.isEmpty) {
      final categoriesResult = await getCategories();
      categoriesResult.fold(
        (failure) => null,
        (categories) => _categories = categories,
      );
    }

    final params = GetDestinationsParams(
      page: event.page,
      limit: event.limit,
      search: event.search,
      categoryId: event.categoryId,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      lat: event.lat,
      lng: event.lng,
      radius: event.radius,
      isOpenNow: event.isOpenNow,
      context: event.context,
      sortBy: event.sortBy,
      hiddenGemsOnly: event.hiddenGemsOnly,
    );

    final result = await getDestinations(params);

    result.fold(
      (failure) => emit(DestinationError(failure.message)),
      (destinationsResult) {
        final hasMore = destinationsResult.currentPage < destinationsResult.totalPages;

        // If loading more, append to existing list
        if (event.loadMore && state is DestinationLoadingMore) {
          final currentState = state as DestinationLoadingMore;
          final updatedDestinations = [
            ...currentState.currentDestinations,
            ...destinationsResult.destinations,
          ];

          emit(DestinationLoaded(
            destinations: updatedDestinations,
            categories: _categories,
            currentPage: destinationsResult.currentPage,
            totalPages: destinationsResult.totalPages,
            total: destinationsResult.total,
            hasMore: hasMore,
          ));
        } else {
          emit(DestinationLoaded(
            destinations: destinationsResult.destinations,
            categories: _categories,
            currentPage: destinationsResult.currentPage,
            totalPages: destinationsResult.totalPages,
            total: destinationsResult.total,
            hasMore: hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onGetCategories(
    GetCategoriesEvent event,
    Emitter<DestinationState> emit,
  ) async {
    final result = await getCategories();

    result.fold(
      (failure) => emit(DestinationError(failure.message)),
      (categories) {
        _categories = categories;
        if (state is DestinationLoaded) {
          final currentState = state as DestinationLoaded;
          emit(currentState.copyWith(categories: categories));
        }
      },
    );
  }

  Future<void> _onLikeDestination(
    LikeDestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    final result = await likeDestination(event.destinationId);

    result.fold(
      (failure) => emit(DestinationError(failure.message)),
      (totalLikes) {
        // Update the destination in the list
        if (state is DestinationLoaded) {
          final currentState = state as DestinationLoaded;
          final updatedDestinations = currentState.destinations.map((dest) {
            if (dest.id == event.destinationId) {
              return Destination(
                id: dest.id,
                categoryId: dest.categoryId,
                name: dest.name,
                description: dest.description,
                address: dest.address,
                lat: dest.lat,
                lng: dest.lng,
                avgCost: dest.avgCost,
                rating: dest.rating,
                totalReviews: dest.totalReviews,
                totalLikes: totalLikes,
                totalSaves: dest.totalSaves,
                totalCheckins: dest.totalCheckins,
                tags: dest.tags,
                openingHours: dest.openingHours,
                images: dest.images,
                aiSummary: dest.aiSummary,
                bestTimeToVisit: dest.bestTimeToVisit,
                recommendedDuration: dest.recommendedDuration,
                isHiddenGem: dest.isHiddenGem,
                challengeTags: dest.challengeTags,
                isVerified: dest.isVerified,
                isFeatured: dest.isFeatured,
                isActive: dest.isActive,
                createdAt: dest.createdAt,
                updatedAt: dest.updatedAt,
                category: dest.category,
              );
            }
            return dest;
          }).toList();

          emit(currentState.copyWith(destinations: updatedDestinations));
          emit(const DestinationActionSuccess('Đã like địa điểm'));
        }
      },
    );
  }

  Future<void> _onSaveDestination(
    SaveDestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    final result = await saveDestination(event.destinationId);

    result.fold(
      (failure) => emit(DestinationError(failure.message)),
      (totalSaves) {
        // Update the destination in the list
        if (state is DestinationLoaded) {
          final currentState = state as DestinationLoaded;
          final updatedDestinations = currentState.destinations.map((dest) {
            if (dest.id == event.destinationId) {
              return Destination(
                id: dest.id,
                categoryId: dest.categoryId,
                name: dest.name,
                description: dest.description,
                address: dest.address,
                lat: dest.lat,
                lng: dest.lng,
                avgCost: dest.avgCost,
                rating: dest.rating,
                totalReviews: dest.totalReviews,
                totalLikes: dest.totalLikes,
                totalSaves: totalSaves,
                totalCheckins: dest.totalCheckins,
                tags: dest.tags,
                openingHours: dest.openingHours,
                images: dest.images,
                aiSummary: dest.aiSummary,
                bestTimeToVisit: dest.bestTimeToVisit,
                recommendedDuration: dest.recommendedDuration,
                isHiddenGem: dest.isHiddenGem,
                challengeTags: dest.challengeTags,
                isVerified: dest.isVerified,
                isFeatured: dest.isFeatured,
                isActive: dest.isActive,
                createdAt: dest.createdAt,
                updatedAt: dest.updatedAt,
                category: dest.category,
              );
            }
            return dest;
          }).toList();

          emit(currentState.copyWith(destinations: updatedDestinations));
          emit(const DestinationActionSuccess('Đã lưu địa điểm'));
        }
      },
    );
  }
}

