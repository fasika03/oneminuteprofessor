import 'package:flutter/material.dart';

/// Reusable button matching the app's style: rounded corners, an
/// optional leading icon, and two visual styles (filled/outlined).
/// Use this instead of raw ElevatedButton/OutlinedButton so every
/// screen's buttons stay visually consistent.
///
/// Example:
/// ```dart
/// CustomButton(
///   label: 'Start Explaining',
///   icon: Icons.arrow_forward,
///   onPressed: _startExplaining,
/// )
///
/// CustomButton(
///   label: 'New Topic',
///   icon: Icons.refresh,
///   style: CustomButtonStyle.outlined,
///   onPressed: _shuffleTopic,
/// )
/// ```
enum CustomButtonStyle { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final Color color;
  final Color foregroundColor;
  final bool isLoading;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.style = CustomButtonStyle.filled,
    this.color = Colors.deepPurple,
    this.foregroundColor = Colors.white,
    this.isLoading = false,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    // Disable taps entirely while a request is in flight, so a
    // double-tap can't fire the action twice (e.g. submitting an
    // answer for grading twice).
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(
                style == CustomButtonStyle.filled ? foregroundColor : color,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );

    switch (style) {
      case CustomButtonStyle.filled:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: foregroundColor,
              disabledBackgroundColor: color.withOpacity(0.4),
              padding: padding,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: child,
          ),
        );

      case CustomButtonStyle.outlined:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: child,
          ),
        );

      case CustomButtonStyle.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(foregroundColor: color),
          child: child,
        );
    }
  }
}
