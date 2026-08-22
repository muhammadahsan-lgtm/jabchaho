import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ContentSurface extends StatelessWidget {
  const ContentSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 24,
    this.inverse = false,
    this.shadowOpacity = 0.06,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool inverse;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: inverse ? AppColors.black : AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: inverse
            ? AppColors.white.withValues(alpha: 0.15)
            : AppColors.black.withValues(alpha: 0.055),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: shadowOpacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
  );
}
