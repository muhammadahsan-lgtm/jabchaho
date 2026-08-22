import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum GlassVariant { clear, regular, prominent }

class LiquidGlass extends StatefulWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.padding,
    this.radius = 24,
    this.blur = 24,
    this.opacity = 0.58,
    this.dark = false,
    this.shadowOpacity = 0.10,
    this.variant = GlassVariant.regular,
    this.tint,
    this.interactive = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blur;
  final double opacity;
  final bool dark;
  final double shadowOpacity;
  final GlassVariant variant;
  final Color? tint;
  final bool interactive;

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  Alignment _lightSource = const Alignment(-0.55, -0.75);

  double get _energy {
    if (_pressed) return 1;
    if (_hovered || _focused) return 0.68;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.highContrastOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 190);
    final tint =
        widget.tint ?? (widget.dark ? AppColors.black : AppColors.white);
    final variantOpacity = switch (widget.variant) {
      GlassVariant.clear => widget.opacity * 0.74,
      GlassVariant.regular => widget.opacity,
      GlassVariant.prominent => math.max(widget.opacity, 0.76),
    };
    final effectiveOpacity = highContrast
        ? math.max(variantOpacity, widget.dark ? 0.88 : 0.82)
        : variantOpacity;
    final effectiveBlur = highContrast ? widget.blur * 0.72 : widget.blur;

    Widget glass = TweenAnimationBuilder<double>(
      tween: Tween(end: _energy),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, energy, child) {
        final pressScale = reduceMotion
            ? 1.0
            : _pressed
            ? 0.985
            : _hovered
            ? 1.004
            : 1.0;
        return AnimatedScale(
          scale: pressScale,
          duration: duration,
          curve: Curves.easeOutCubic,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: (0.08 * energy).clamp(0, 1)),
                  blurRadius: 18 + (12 * energy),
                  spreadRadius: energy * 1.5,
                ),
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: widget.shadowOpacity * (1 - energy * 0.18),
                  ),
                  blurRadius:
                      28 + (widget.variant == GlassVariant.prominent ? 8 : 0),
                  offset: Offset(0, 12 - energy * 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tint.withValues(
                          alpha: (effectiveOpacity + 0.07).clamp(0, 1),
                        ),
                        tint.withValues(alpha: effectiveOpacity.clamp(0, 1)),
                        tint.withValues(
                          alpha: (effectiveOpacity - 0.10).clamp(0, 1),
                        ),
                      ],
                      stops: const [0, 0.52, 1],
                    ),
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  child: CustomPaint(
                    foregroundPainter: _GlassOpticsPainter(
                      radius: widget.radius,
                      dark: widget.dark,
                      highContrast: highContrast,
                      energy: energy,
                      lightSource: _lightSource,
                    ),
                    child: Padding(
                      padding: widget.padding ?? EdgeInsets.zero,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );

    if (!widget.interactive) return glass;

    glass = FocusableActionDetector(
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
          _lightSource = const Alignment(-0.55, -0.75);
        }),
        onHover: (event) => _updateLight(event.localPosition, context),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            setState(() => _pressed = true);
            _updateLight(event.localPosition, context);
          },
          onPointerMove: (event) => _updateLight(event.localPosition, context),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: glass,
        ),
      ),
    );
    return glass;
  }

  void _updateLight(Offset localPosition, BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return;
    final x = ((localPosition.dx / box.size.width) * 2 - 1).clamp(-1.0, 1.0);
    final y = ((localPosition.dy / box.size.height) * 2 - 1).clamp(-1.0, 1.0);
    final next = Alignment(x, y);
    if ((next.x - _lightSource.x).abs() < 0.03 &&
        (next.y - _lightSource.y).abs() < 0.03) {
      return;
    }
    setState(() => _lightSource = next);
  }
}

class _GlassOpticsPainter extends CustomPainter {
  const _GlassOpticsPainter({
    required this.radius,
    required this.dark,
    required this.highContrast,
    required this.energy,
    required this.lightSource,
  });

  final double radius;
  final bool dark;
  final bool highContrast;
  final double energy;
  final Alignment lightSource;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.6),
      Radius.circular(radius),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    final glow = Paint()
      ..shader = RadialGradient(
        center: lightSource,
        radius: 0.76,
        colors: [
          AppColors.white.withValues(alpha: 0.08 + energy * 0.20),
          AppColors.white.withValues(alpha: energy * 0.035),
          Colors.transparent,
        ],
        stops: const [0, 0.52, 1],
      ).createShader(rect);
    canvas.drawRect(rect, glow);

    final depth = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.black.withValues(alpha: dark ? 0.10 : 0.035),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, depth);
    canvas.restore();

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 1.5 : 1.0
      ..shader = SweepGradient(
        startAngle: -math.pi,
        endAngle: math.pi,
        colors: [
          AppColors.white.withValues(alpha: dark ? 0.26 : 0.95),
          AppColors.white.withValues(alpha: 0.38 + energy * 0.30),
          AppColors.black.withValues(alpha: dark ? 0.24 : 0.07),
          AppColors.white.withValues(alpha: dark ? 0.22 : 0.84),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, rim);

    final lensRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = AppColors.white.withValues(alpha: 0.12 + energy * 0.12);
    canvas.drawRRect(rrect.deflate(2.0), lensRim);
  }

  @override
  bool shouldRepaint(covariant _GlassOpticsPainter oldDelegate) =>
      oldDelegate.energy != energy ||
      oldDelegate.lightSource != lightSource ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.dark != dark ||
      oldDelegate.radius != radius;
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
          opacity: 0.42,
          shadowOpacity: 0.06,
          interactive: true,
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
