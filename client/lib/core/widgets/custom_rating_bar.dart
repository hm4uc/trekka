import 'package:flutter/material.dart';

class CustomRatingBar extends StatelessWidget {
  final double rating;
  final Function(double)? onRatingUpdate;
  final int itemCount;
  final double itemSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomRatingBar({
    super.key,
    required this.rating,
    this.onRatingUpdate,
    this.itemCount = 5,
    this.itemSize = 40.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return GestureDetector(
          onTap: onRatingUpdate != null
              ? () => onRatingUpdate!(index + 1.0)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating
                ? (activeColor ?? Colors.amber)
                : (inactiveColor ?? Colors.grey),
            size: itemSize,
          ),
        );
      }),
    );
  }
}

class CustomRatingBarIndicator extends StatelessWidget {
  final double rating;
  final int itemCount;
  final double itemSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomRatingBarIndicator({
    super.key,
    required this.rating,
    this.itemCount = 5,
    this.itemSize = 20.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating
              ? (activeColor ?? Colors.amber)
              : (inactiveColor ?? Colors.grey),
          size: itemSize,
        );
      }),
    );
  }
}

