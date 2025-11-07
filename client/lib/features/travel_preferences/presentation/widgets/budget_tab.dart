import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trekka/features/travel_preferences/presentation/bloc/travel_preferences_bloc.dart';

class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelPreferencesBloc, TravelPreferencesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your budget range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: state.budgetLevels.entries.map((entry) {
                    final level = entry.key;
                    final range = entry.value;
                    final isSelected = state.selectedBudget == level;

                    return GestureDetector(
                      onTap: () {
                        context.read<TravelPreferencesBloc>().add(
                          SelectBudgetLevel(level: level),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4F6EF7) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4F6EF7) : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.white : Colors.grey[300],
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF4F6EF7) : Colors.grey[400]!,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                Icons.check,
                                size: 16,
                                color: const Color(0xFF4F6EF7),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getBudgetLevelTitle(level),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.grey[800],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${range['min']} - ${range['max']} VND',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getBudgetLevelTitle(String level) {
    switch (level) {
      case 'LOW':
        return 'Tiết kiệm';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HIGH':
        return 'Cao cấp';
      case 'LUXURY':
        return 'Sang trọng';
      default:
        return level;
    }
  }
}