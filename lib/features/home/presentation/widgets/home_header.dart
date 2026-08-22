import 'package:flutter/material.dart';

import '../../../../core/layout/adaptive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/content_surface.dart';
import '../../../../core/widgets/liquid_glass.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onAiPressed});

  final VoidCallback onAiPressed;

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveMetrics.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandMark(),
            const SizedBox(width: 10),
            const Expanded(child: _LocationIdentity()),
            GlassIconButton(
              icon: Icons.auto_awesome_rounded,
              tooltip: 'Ask JabChaho AI',
              onPressed: onAiPressed,
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              badge: true,
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(height: metrics.isCompact ? 24 : 32),
        const Row(
          children: [
            Expanded(
              child: Text(
                'Good morning, Ali.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SyncPill(),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'What can we handle?',
          maxLines: 2,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontSize: metrics.isCompact ? 32 : 38),
        ),
      ],
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(size * 0.34),
      boxShadow: [
        BoxShadow(
          color: AppColors.yellow.withValues(alpha: 0.34),
          blurRadius: 20,
        ),
      ],
    ),
    child: Text(
      'J',
      style: TextStyle(fontSize: size * 0.52, fontWeight: FontWeight.w900),
    ),
  );
}

class _LocationIdentity extends StatelessWidget {
  const _LocationIdentity();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'JABCHAHO',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),
      SizedBox(height: 1),
      Row(
        children: [
          Icon(Icons.location_on_rounded, size: 13),
          SizedBox(width: 2),
          Flexible(
            child: Text(
              'Home · DHA Phase 6',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 15),
        ],
      ),
    ],
  );
}

class SyncPill extends StatelessWidget {
  const SyncPill({super.key});

  @override
  Widget build(BuildContext context) => ContentSurface(
    radius: 13,
    shadowOpacity: 0.025,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_done_rounded, size: 13),
        SizedBox(width: 5),
        Text(
          'Synced',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class CollapsedHomeHeader extends StatelessWidget {
  const CollapsedHomeHeader({super.key, required this.onAiPressed});

  final VoidCallback onAiPressed;

  @override
  Widget build(BuildContext context) => LiquidGlass(
    radius: 22,
    blur: 28,
    opacity: 0.78,
    shadowOpacity: 0.10,
    padding: const EdgeInsets.fromLTRB(8, 7, 7, 7),
    child: Row(
      children: [
        const BrandMark(size: 34),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'JABCHAHO',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Home · DHA Phase 6',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onAiPressed,
          tooltip: 'Ask JabChaho AI',
          constraints: const BoxConstraints.tightFor(width: 38, height: 38),
          icon: const Icon(Icons.auto_awesome_rounded, size: 19),
        ),
      ],
    ),
  );
}
