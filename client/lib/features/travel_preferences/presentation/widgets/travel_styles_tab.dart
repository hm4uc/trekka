import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trekka/features/travel_preferences/presentation/bloc/travel_preferences_bloc.dart';

class TravelStylesTab extends StatelessWidget {
  const TravelStylesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelPreferencesBloc, TravelPreferencesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: state.availableStyles.length,
            itemBuilder: (context, index) {
              final style = state.availableStyles[index];
              final isSelected = state.selectedStyles.contains(style);

              return GestureDetector(
                onTap: () {
                  context.read<TravelPreferencesBloc>().add(
                    ToggleTravelStyle(style: style),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4F6EF7) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4F6EF7) : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getStyleIcon(style),
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        style,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getStyleIcon(String style) {
    switch (style) {
      case 'Du lịch nghỉ dưỡng':
        return Icons.beach_access;
      case 'Du lịch khám phá':
        return Icons.explore;
      case 'Du lịch mạo hiểm':
        return Icons.landscape;
      case 'Du lịch văn hóa':
        return Icons.museum;
      case 'Du lịch ẩm thực':
        return Icons.restaurant;
      case 'Du lịch sinh thái':
        return Icons.park;
      case 'Du lịch thể thao':
        return Icons.sports_baseball;
      case 'Du lịch tâm linh':
        return Icons.self_improvement;
      case 'Du lịch shopping':
        return Icons.shopping_bag;
      case 'Du lịch gia đình':
        return Icons.family_restroom;
      case 'Du lịch một mình':
        return Icons.person;
      case 'Du lịch cặp đôi':
        return Icons.favorite;
      case 'Du lịch với bạn bè':
        return Icons.group;
      case 'Du lịch công tác':
        return Icons.business_center;
      default:
        return Icons.flag;
    }
  }
}