import 'package:flutter/material.dart';

/// Reusable primary action button used across forms.
///
/// Supports:
/// - Loading state (disables button and shows spinner)
/// - Optional leading icon
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: icon == null
          ? FilledButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            )
          : FilledButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(icon),
              label: child,
            ),
    );
  }
}
