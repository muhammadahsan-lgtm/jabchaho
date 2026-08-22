import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.padding,
    this.radius = 24,
    this.blur = 24,
    this.opacity = 0.58,
    this.dark = false,
    this.shadowOpacity = 0.10,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blur;
  final double opacity;
  final bool dark;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final tint = dark ? AppColors.black : AppColors.white;
    final edge = dark
        ? AppColors.white.withValues(alpha: 0.18)
        : AppColors.white.withValues(alpha: 0.92);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: shadowOpacity),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: opacity + 0.08),
                  tint.withValues(alpha: opacity),
                  tint.withValues(alpha: (opacity - 0.08).clamp(0, 1)),
                ],
              ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: edge),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Padding(padding: padding ?? EdgeInsets.zero, child: child),
                Positioned(
                  top: 1,
                  left: radius * 0.7,
                  right: radius * 1.2,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.white.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
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

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badge = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        LiquidGlass(
          radius: 16,
          blur: 18,
          opacity: 0.45,
          shadowOpacity: 0.06,
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            icon: Icon(icon, size: 21),
          ),
        ),
        if (badge)
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.yellow, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
