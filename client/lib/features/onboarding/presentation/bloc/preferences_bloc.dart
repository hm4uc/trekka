import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/travel_constants.dart';
import '../../domain/usecases/get_travel_constants.dart';
import '../../domain/usecases/update_travel_settings.dart';

// --- EVENTS ---
abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class GetTravelConstantsEvent extends PreferencesEvent {}

class UpdateTravelSettingsEvent extends PreferencesEvent {
  final String ageGroup;
  final List<String> preferences;
  final double? budget;

  const UpdateTravelSettingsEvent({
    required this.ageGroup,
    required this.preferences,
    this.budget,
  });
}

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

class PreferencesUpdateSuccess extends PreferencesState {}

// --- BLOC ---
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetTravelConstants getTravelConstants;
  final UpdateTravelSettings updateTravelSettings;

  PreferencesBloc({required this.getTravelConstants, required this.updateTravelSettings})
      : super(PreferencesInitial()) {
    on<GetTravelConstantsEvent>(_onGetTravelConstants);
    on<UpdateTravelSettingsEvent>(_onUpdateSettings);
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

  Future<void> _onUpdateSettings(
    UpdateTravelSettingsEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    // Lưu lại state hiện tại (nếu đang loaded) để không bị mất giao diện khi loading
    // Hoặc emit loading đè lên
    emit(PreferencesLoading());

    final result = await updateTravelSettings(UpdateTravelSettingsParams(
      ageGroup: event.ageGroup,
      preferences: event.preferences,
      budget: event.budget,
    ));

    result.fold(
      (failure) => emit(PreferencesError(failure.message)),
      (_) => emit(PreferencesUpdateSuccess()), // Thành công
    );
  }
}