import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Colors.white, Color(0xFFFDF2F2)],
                  radius: 0.85,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.danger.withAlpha(45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.danger.withAlpha(20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 38,
                  color: AppTheme.danger,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.danger.withAlpha(70)),
                      boxShadow: AppTheme.cardShadowSubtle,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 16, color: AppTheme.danger),
                        SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            color: AppTheme.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

