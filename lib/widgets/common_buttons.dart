// lib/widgets/common_buttons.dart
import 'package:flutter/material.dart';
import 'package:fruit_game/config/app_colors.dart';

class FruitGameElevatedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const FruitGameElevatedButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor ?? AppColors.accentYellow,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
          Text(text),
        ],
      ),
    );
  }
}
