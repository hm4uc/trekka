import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';

class TravelStyleFilter extends StatelessWidget {
  final String? selectedTravelStyle;
  final Function(String?) onStyleSelected;

  const TravelStyleFilter({
    super.key,
    required this.selectedTravelStyle,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final travelStyles = [
      {'id': null, 'name': 'Tất cả', 'icon': Icons.explore},
      {'id': 'nature', 'name': 'Thiên nhiên', 'icon': Icons.nature},
      {'id': 'food_drink', 'name': 'Ẩm thực', 'icon': Icons.restaurant_menu},
      {'id': 'culture_history', 'name': 'Văn hóa', 'icon': Icons.museum},
      {'id': 'shopping_entertainment', 'name': 'Giải trí', 'icon': Icons.shopping_bag},
      {'id': 'local_life', 'name': 'Địa phương', 'icon': Icons.location_city},
    ];

    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: travelStyles.length,
        itemBuilder: (context, index) {
          final style = travelStyles[index];
          final isSelected = selectedTravelStyle == style['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildStyleChip(
              label: style['name'] as String,
              icon: style['icon'] as IconData,
              isSelected: isSelected,
              onTap: () => onStyleSelected(style['id'] as String?),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStyleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isSelected ? null : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

