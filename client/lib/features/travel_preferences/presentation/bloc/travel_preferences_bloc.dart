import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TravelPreferencesEvent {}

class LoadTravelConstants extends TravelPreferencesEvent {}

class ToggleTravelStyle extends TravelPreferencesEvent {
  final String style;

  ToggleTravelStyle({required this.style});
}

class SelectBudgetLevel extends TravelPreferencesEvent {
  final String level;

  SelectBudgetLevel({required this.level});
}

class SaveTravelPreferences extends TravelPreferencesEvent {
  final List<String> styles;
  final double budget;

  SaveTravelPreferences({required this.styles, required this.budget});
}

class TravelPreferencesState {
  final List<String> availableStyles;
  final Map<String, Map<String, dynamic>> budgetLevels;
  final List<String> selectedStyles;
  final String? selectedBudget;
  final bool isLoading;
  final bool isSaving;

  TravelPreferencesState({
    required this.availableStyles,
    required this.budgetLevels,
    required this.selectedStyles,
    this.selectedBudget,
    this.isLoading = false,
    this.isSaving = false,
  });

  TravelPreferencesState copyWith({
    List<String>? availableStyles,
    Map<String, Map<String, dynamic>>? budgetLevels,
    List<String>? selectedStyles,
    String? selectedBudget,
    bool? isLoading,
    bool? isSaving,
  }) {
    return TravelPreferencesState(
      availableStyles: availableStyles ?? this.availableStyles,
      budgetLevels: budgetLevels ?? this.budgetLevels,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      selectedBudget: selectedBudget ?? this.selectedBudget,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class TravelPreferencesBloc extends Bloc<TravelPreferencesEvent, TravelPreferencesState> {
  TravelPreferencesBloc() : super(TravelPreferencesState(
    availableStyles: const [
      "Du lịch nghỉ dưỡng",
      "Du lịch khám phá",
      "Du lịch mạo hiểm",
      "Du lịch văn hóa",
      "Du lịch ẩm thực",
      "Du lịch sinh thái",
      "Du lịch thể thao",
      "Du lịch tâm linh",
      "Du lịch shopping",
      "Du lịch gia đình",
      "Du lịch một mình",
      "Du lịch cặp đôi",
      "Du lịch với bạn bè",
      "Du lịch công tác"
    ],
    budgetLevels: const {
      'LOW': {'min': 0, 'max': 3000000, 'label': 'Tiết kiệm (0-3 triệu)'},
      'MEDIUM': {'min': 3000000, 'max': 7000000, 'label': 'Trung bình (3-7 triệu)'},
      'HIGH': {'min': 7000000, 'max': 15000000, 'label': 'Cao cấp (7-15 triệu)'},
      'LUXURY': {'min': 15000000, 'max': 50000000, 'label': 'Sang trọng (15-50 triệu)'}
    },
    selectedStyles: [],
  )) {
    on<ToggleTravelStyle>(_onToggleTravelStyle);
    on<SelectBudgetLevel>(_onSelectBudgetLevel);
    on<SaveTravelPreferences>(_onSaveTravelPreferences);
  }

  void _onToggleTravelStyle(ToggleTravelStyle event, Emitter<TravelPreferencesState> emit) {
    final List<String> updatedStyles = List.from(state.selectedStyles);

    if (updatedStyles.contains(event.style)) {
      updatedStyles.remove(event.style);
    } else {
      updatedStyles.add(event.style);
    }

    emit(state.copyWith(selectedStyles: updatedStyles));
  }

  void _onSelectBudgetLevel(SelectBudgetLevel event, Emitter<TravelPreferencesState> emit) {
    emit(state.copyWith(selectedBudget: event.level));
  }

  void _onSaveTravelPreferences(SaveTravelPreferences event, Emitter<TravelPreferencesState> emit) async {
    emit(state.copyWith(isSaving: true));

    // Here you would typically make an API call to save the preferences
    // For now, we'll simulate a delay and then navigate
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(isSaving: false));
  }
}