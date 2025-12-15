import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../destinations/domain/entities/destination.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<DestinationCategory> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // "All" chip
          _buildChip(
            label: "Tất cả",
            icon: Icons.grid_view,
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),

          // Category chips
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: category.name,
                  icon: _getIconFromName(category.icon),
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => onCategorySelected(category.id),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    // Map icon names to Flutter Icons
    switch (iconName.toLowerCase()) {
      case 'coffee':
        return Icons.coffee;
      case 'palette':
        return Icons.palette;
      case 'glass-cheers':
      case 'cocktail':
        return Icons.local_bar;
      case 'monument':
        return Icons.museum; // Flutter doesn't have monument, use museum
      case 'water':
        return Icons.water;
      case 'landmark':
        return Icons.account_balance;
      case 'tree':
      case 'park':
        return Icons.park;
      case 'utensils':
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping-bag':
        return Icons.shopping_bag;
      case 'hamburger':
        return Icons.fastfood;
      case 'umbrella-beach':
      case 'beach':
        return Icons.beach_access;
      case 'mountain':
        return Icons.terrain;
      case 'temple':
        return Icons.temple_buddhist;
      case 'film':
      case 'movie':
        return Icons.movie;
      case 'city':
        return Icons.location_city;
      case 'spa':
        return Icons.spa;
      case 'store':
        return Icons.store;
      default:
        return Icons.place;
    }
  }
}

