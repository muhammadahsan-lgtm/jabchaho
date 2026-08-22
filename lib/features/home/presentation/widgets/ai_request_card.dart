import 'package:flutter/material.dart';

import '../../../../core/layout/adaptive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/liquid_glass.dart';

class AiRequestCard extends StatelessWidget {
  const AiRequestCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = AdaptiveMetrics.of(context).isCompact;
    return LiquidGlass(
      dark: true,
      radius: 28,
      blur: 28,
      opacity: 0.90,
      shadowOpacity: 0.20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              const Positioned(right: -38, top: -55, child: _YellowGlow()),
              Padding(
                padding: EdgeInsets.all(compact ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.yellow,
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'JABCHAHO AI',
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 11 : 14),
                    Text(
                      'Say it. Consider it done.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'One request can combine food, errands and delivery.',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.62),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: compact ? 14 : 24),
                    Semantics(
                      button: true,
                      label: 'Ask JabChaho AI',
                      child: LiquidGlass(
                        radius: 18,
                        blur: 14,
                        opacity: 0.08,
                        dark: false,
                        shadowOpacity: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: const Key('ai-intent-button'),
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15, 10, 9, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '“Get dinner and my usual medicine”',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.76,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mic_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YellowGlow extends StatelessWidget {
  const _YellowGlow();

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    height: 160,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.yellow.withValues(alpha: 0.18),
      boxShadow: [
        BoxShadow(
          color: AppColors.yellow.withValues(alpha: 0.16),
          blurRadius: 65,
          spreadRadius: 10,
        ),
      ],
    ),
  );
}
