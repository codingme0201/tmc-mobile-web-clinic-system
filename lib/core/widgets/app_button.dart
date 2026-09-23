import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.height = 52,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = backgroundColor == null && gradient == null
        ? AppTheme.primaryGradient
        : gradient;
    final isInteractive = onPressed != null && !isLoading;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveGradient == null
            ? (backgroundColor ?? AppTheme.primary)
            : null,
        gradient: isInteractive ? effectiveGradient : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isInteractive
            ? (backgroundColor == AppTheme.danger
                ? [
                    BoxShadow(
                      color: AppTheme.danger.withAlpha(50),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ]
                : AppTheme.primaryGlow)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: foregroundColor ?? Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor ?? Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
