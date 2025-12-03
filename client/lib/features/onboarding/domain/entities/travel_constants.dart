import 'package:equatable/equatable.dart';

// Entity tổng hợp
class TravelConstants extends Equatable {
  final List<TravelStyle> styles;
  final BudgetConfig budgetConfig;

  const TravelConstants({required this.styles, required this.budgetConfig});

  @override
  List<Object?> get props => [styles, budgetConfig];
}

// Entity con: TravelStyle
class TravelStyle extends Equatable {
  final String id;
  final String label;
  final String icon;
  final String description;

  const TravelStyle({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });

  @override
  List<Object?> get props => [id, label, icon, description];
}

// Entity con: BudgetConfig
class BudgetConfig extends Equatable {
  final double min;
  final double max;
  final double step;
  final double defaultValue;
  final String currency;

  const BudgetConfig({
    required this.min,
    required this.max,
    required this.step,
    required this.defaultValue,
    required this.currency,
  });

  @override
  List<Object?> get props => [min, max, step, defaultValue, currency];
}