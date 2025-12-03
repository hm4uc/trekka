import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/travel_constants.dart';
import '../../domain/usecases/get_travel_constants.dart';

// --- EVENTS ---
abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();
  @override
  List<Object> get props => [];
}

class GetTravelConstantsEvent extends PreferencesEvent {}

// --- STATES ---
abstract class PreferencesState extends Equatable {
  const PreferencesState();
  @override
  List<Object> get props => [];
}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {
  final TravelConstants constants;
  const PreferencesLoaded(this.constants);
  @override
  List<Object> get props => [constants];
}

class PreferencesError extends PreferencesState {
  final String message;
  const PreferencesError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetTravelConstants getTravelConstants;

  PreferencesBloc({required this.getTravelConstants}) : super(PreferencesInitial()) {
    on<GetTravelConstantsEvent>(_onGetTravelConstants);
  }

  Future<void> _onGetTravelConstants(
      GetTravelConstantsEvent event,
      Emitter<PreferencesState> emit,
      ) async {
    emit(PreferencesLoading());
    final result = await getTravelConstants(NoParams());
    result.fold(
          (failure) => emit(PreferencesError(failure.message)),
          (constants) => emit(PreferencesLoaded(constants)),
    );
  }
}