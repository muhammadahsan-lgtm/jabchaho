import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/layout/adaptive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../domain/home_models.dart';

class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.white,
    child: Stack(
      children: [
        Positioned(
          left: -100,
          top: -90,
          child: _BlurredOrb(
            size: 280,
            color: AppColors.yellow.withValues(alpha: 0.42),
            blur: 42,
          ),
        ),
        Positioned(
          right: -105,
          top: 260,
          child: _BlurredOrb(
            size: 230,
            color: AppColors.yellow.withValues(alpha: 0.23),
            blur: 58,
          ),
        ),
        Positioned(
          left: -75,
          bottom: 80,
          child: _BlurredOrb(
            size: 190,
            color: AppColors.black.withValues(alpha: 0.045),
            blur: 60,
          ),
        ),
      ],
    ),
  );
}

class _BlurredOrb extends StatelessWidget {
  const _BlurredOrb({
    required this.size,
    required this.color,
    required this.blur,
  });

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
      if (action != null)
        TextButton.icon(
          onPressed: onAction ?? () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.muted,
            backgroundColor: AppColors.black.withValues(alpha: 0.035),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          label: Text(
            action!,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 13),
          iconAlignment: IconAlignment.end,
        ),
    ],
  );
}

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({
    super.key,
    required this.services,
    required this.onSelected,
  });

  final List<ServiceCategory> services;
  final ValueChanged<ServiceCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveMetrics.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: metrics.serviceColumns,
        mainAxisExtent: metrics.isCompact ? 104 : 112,
        crossAxisSpacing: metrics.isCompact ? 8 : 14,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => ServiceCard(
        service: services[index],
        onTap: () => onSelected(services[index]),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final ServiceCategory service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${service.name}, ${service.detail}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            LiquidGlass(
              radius: 20,
              blur: 18,
              opacity: service.isMore ? 0.92 : 0.68,
              dark: service.isMore,
              shadowOpacity: service.isMore ? 0.10 : 0.09,
              child: SizedBox(
                width: 58,
                height: 58,
                child: Icon(
                  service.icon,
                  size: 25,
                  color: service.isMore ? AppColors.white : AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              service.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionList extends StatefulWidget {
  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  final List<SmartSuggestion> suggestions;
  final ValueChanged<SmartSuggestion> onSelected;

  @override
  State<SuggestionList> createState() => _SuggestionListState();
}

class _SuggestionListState extends State<SuggestionList> {
  final ScrollController _controller = ScrollController();
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateHint);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateHint)
      ..dispose();
    super.dispose();
  }

  void _updateHint() {
    final shouldShow = _controller.offset < 18;
    if (shouldShow == _showHint) return;
    setState(() => _showHint = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveMetrics.of(context);
    if (!metrics.isCompact) {
      return Row(
        children: [
          for (var index = 0; index < widget.suggestions.length; index++) ...[
            Expanded(
              child: SizedBox(
                height: 160,
                child: SuggestionCard(
                  suggestion: widget.suggestions[index],
                  onTap: () => widget.onSelected(widget.suggestions[index]),
                ),
              ),
            ),
            if (index != widget.suggestions.length - 1)
              const SizedBox(width: 14),
          ],
        ],
      );
    }

    return SizedBox(
      height: 156,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            ListView.separated(
              controller: _controller,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: (constraints.maxWidth * 0.82).clamp(260, 320),
                child: SuggestionCard(
                  suggestion: widget.suggestions[index],
                  onTap: () => widget.onSelected(widget.suggestions[index]),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _showHint ? 1 : 0,
                  child: Container(
                    width: 44,
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.white.withValues(alpha: 0),
                          AppColors.white.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                    child: Container(
                      width: 26,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.chevron_right_rounded, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  final SmartSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: suggestion.isHighlighted ? AppColors.yellow : AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.75)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.eyebrow,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        suggestion.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 17,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.45,
                        ),
                      ),
                    ),
                    Text(
                      suggestion.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({super.key, required this.order});

  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: 25,
      blur: 24,
      opacity: 0.60,
      shadowOpacity: 0.07,
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(order.icon),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  order.eta,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: order.progress,
              minHeight: 6,
              backgroundColor: AppColors.black.withValues(alpha: 0.07),
              valueColor: const AlwaysStoppedAnimation(AppColors.black),
            ),
          ),
          const SizedBox(height: 9),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Confirmed',
                  style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                ),
              ),
              Expanded(
                child: Text(
                  'Picked up',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: Text(
                  'At your door',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
