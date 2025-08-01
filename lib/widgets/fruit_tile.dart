// lib/widgets/fruit_tile.dart
import 'package:flutter/material.dart';
import 'package:fruit_game/config/app_colors.dart';

class FruitTile extends StatelessWidget {
  final int number; // 0 means empty, 1-9 means a number
  final bool isSelected;
  final bool isTargetHighlight; // For visual feedback on hovered cells

  const FruitTile({
    super.key,
    required this.number,
    this.isSelected = false,
    this.isTargetHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), // Smooth transition for selection
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: number == 0
            ? Colors.transparent // Empty space
            : isSelected
                ? AppColors.accentYellow.withOpacity(0.7) // Selected color
                : AppColors.redApple.withOpacity(0.9), // Apple color
        borderRadius: BorderRadius.circular(8),
        border: isTargetHighlight
            ? Border.all(color: AppColors.accentYellow, width: 3) // Highlight target cells
            : Border.all(
                color: number == 0 ? Colors.transparent : AppColors.secondaryBackground.withOpacity(0.5),
                width: 1.0,
              ),
        boxShadow: number != 0 && !isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: number == 0
          ? null // Don't show anything for empty cells
          : Text(
              number.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
    );
  }
}