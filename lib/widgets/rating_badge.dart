import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Compact rating pill showing star icon and formatted rating score.
class RatingBadge extends StatelessWidget {
  final double rating;
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;
  final bool showStar;

  const RatingBadge({
    Key? key,
    required this.rating,
    this.fontSize = 12,
    this.iconSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
    this.showStar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStar) ...[
            Icon(Icons.star_rounded, color: AppTheme.primary, size: iconSize),
            const SizedBox(width: 3),
          ],
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
