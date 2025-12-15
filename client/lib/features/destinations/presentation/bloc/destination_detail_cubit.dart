import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_destination_by_id.dart';
import '../../domain/usecases/get_nearby_destinations.dart';
import '../../domain/usecases/like_destination.dart';
import '../../domain/usecases/save_destination.dart';
import '../../domain/usecases/checkin_destination.dart';
import 'destination_detail_state.dart';

class DestinationDetailCubit extends Cubit<DestinationDetailState> {
  final GetDestinationById getDestinationById;
  final GetNearbyDestinations getNearbyDestinations;
  final LikeDestination likeDestination;
  final SaveDestination saveDestination;
  final CheckinDestination checkinDestination;

  DestinationDetailCubit({
    required this.getDestinationById,
    required this.getNearbyDestinations,
    required this.likeDestination,
    required this.saveDestination,
    required this.checkinDestination,
  }) : super(DestinationDetailInitial());

  Future<void> loadDestinationDetail(String destinationId) async {
    emit(DestinationDetailLoading());

    final result = await getDestinationById(destinationId);

    result.fold(
      (failure) => emit(DestinationDetailError(failure.message)),
      (destination) async {
        // Load nearby destinations in parallel
        final nearbyResult = await getNearbyDestinations(destinationId);

        nearbyResult.fold(
          (failure) {
            // Still show destination even if nearby fails
            emit(DestinationDetailLoaded(destination: destination));
          },
          (nearby) {
            emit(DestinationDetailLoaded(
              destination: destination,
              nearbyDestinations: nearby,
            ));
          },
        );
      },
    );
  }

  Future<void> toggleLike() async {
    final currentState = state;
    if (currentState is! DestinationDetailLoaded) return;

    final destinationId = currentState.destination.id;
    final isCurrentlyLiked = currentState.isLiked;

    // Optimistically update UI
    emit(currentState.copyWith(isLiked: !isCurrentlyLiked));

    final result = await likeDestination(destinationId);

    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState.copyWith(isLiked: isCurrentlyLiked));
        emit(DestinationDetailActionError(failure.message));
        // Restore the loaded state after showing error
        Future.delayed(const Duration(seconds: 2), () {
          if (state is DestinationDetailActionError) {
            emit(currentState.copyWith(isLiked: isCurrentlyLiked));
          }
        });
      },
      (newLikeCount) {
        // Success - the like count is updated on the server
        // The optimistic update is already applied to the UI
        // You could reload the destination here if needed
      },
    );
  }

  Future<void> toggleSave() async {
    final currentState = state;
    if (currentState is! DestinationDetailLoaded) return;

    final destinationId = currentState.destination.id;
    final isCurrentlySaved = currentState.isSaved;

    // Optimistically update UI
    emit(currentState.copyWith(isSaved: !isCurrentlySaved));

    final result = await saveDestination(destinationId);

    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState.copyWith(isSaved: isCurrentlySaved));
        emit(DestinationDetailActionError(failure.message));
        // Restore the loaded state after showing error
        Future.delayed(const Duration(seconds: 2), () {
          if (state is DestinationDetailActionError) {
            emit(currentState.copyWith(isSaved: isCurrentlySaved));
          }
        });
      },
      (newSaveCount) {
        // Success - keep the optimistic update
      },
    );
  }

  Future<void> performCheckin() async {
    final currentState = state;
    if (currentState is! DestinationDetailLoaded) return;

    final destinationId = currentState.destination.id;

    final result = await checkinDestination(destinationId);

    result.fold(
      (failure) {
        emit(DestinationDetailActionError(failure.message));
        // Restore the loaded state after showing error
        Future.delayed(const Duration(seconds: 2), () {
          if (state is DestinationDetailActionError) {
            emit(currentState);
          }
        });
      },
      (newCheckinCount) {
        emit(const DestinationDetailActionSuccess('Check-in thành công!'));
        // Restore the loaded state after showing success
        Future.delayed(const Duration(seconds: 2), () {
          if (state is DestinationDetailActionSuccess) {
            emit(currentState);
          }
        });
      },
    );
  }
}

