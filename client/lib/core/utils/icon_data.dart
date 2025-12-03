// Helper map icon string từ API sang Flutter Icon
import 'package:flutter/material.dart';

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'mountain': return Icons.landscape;
    case 'temple': return Icons.temple_buddhist;
    case 'utensils': return Icons.restaurant;
    case 'umbrella-beach': return Icons.beach_access;
    case 'hiking': return Icons.hiking;
    case 'shopping-bag': return Icons.shopping_bag;
    case 'gem': return Icons.diamond;
    case 'home': return Icons.home_work; // Local life
    default: return Icons.category;
  }
}