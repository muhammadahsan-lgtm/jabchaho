import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_modal.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../domain/home_models.dart';
import '../domain/home_repository.dart';
import 'widgets/ai_request_card.dart';
import 'widgets/dashboard_widgets.dart';
import 'widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});

  final HomeRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showCollapsedHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 170;
    if (shouldShow == _showCollapsedHeader) return;
    setState(() => _showCollapsedHeader = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.repository.loadDashboard();
    final metrics = AdaptiveMetrics.of(context);

    return Stack(
      children: [
        const Positioned.fill(child: AmbientBackdrop()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: metrics.bottomClearance),
            child: AdaptiveCenter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  metrics.gutter,
                  12,
                  metrics.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeader(onAiPressed: () => _showAiSheet(context)),
                    SizedBox(height: metrics.isCompact ? 22 : 28),
                    _HeroArea(
                      data: data,
                      onAiPressed: () => _showAiSheet(context),
                    ),
                    SizedBox(height: metrics.isCompact ? 28 : 36),
                    const SectionHeader(
                      title: 'What do you need?',
                      action: 'Customize',
                    ),
                    const SizedBox(height: 14),
                    ServiceGrid(
                      services: data.services,
                      onSelected: (service) =>
                          _showServiceSheet(context, service),
                    ),
                    SizedBox(height: metrics.isCompact ? 18 : 30),
                    const SectionHeader(title: 'Picked for your day'),
                    const SizedBox(height: 13),
                    SuggestionList(
                      suggestions: data.suggestions,
                      onSelected: (_) => _confirmSmartAction(context),
                    ),
                    if (!metrics.isExpanded) ...[
                      const SizedBox(height: 30),
                      const SectionHeader(
                        title: 'Happening now',
                        action: 'View order',
                      ),
                      const SizedBox(height: 13),
                      ActiveOrderCard(order: data.activeOrder),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!metrics.isExpanded)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 92,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                opacity: _showCollapsedHeader ? 1 : 0,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.white,
                        Color(0xD9FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: [0, 0.58, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!metrics.isExpanded)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: metrics.gutter,
            right: metrics.gutter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _showCollapsedHeader
                  ? CollapsedHomeHeader(
                      key: const ValueKey('collapsed-home-header'),
                      onAiPressed: () => _showAiSheet(context),
                    )
                  : const SizedBox.shrink(key: ValueKey('header-placeholder')),
            ),
          ),
      ],
    );
  }

  void _showAiSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    AdaptiveModal.show<void>(
      context: context,
      maxWidth: 640,
      builder: (_) => const AiPromptSheet(),
    );
  }

  void _showServiceSheet(BuildContext context, ServiceCategory service) {
    HapticFeedback.lightImpact();
    AdaptiveModal.show<void>(
      context: context,
      maxWidth: 620,
      builder: (_) => ServiceSheet(service: service),
    );
  }

  void _confirmSmartAction(BuildContext context) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.yellow),
            SizedBox(width: 10),
            Expanded(child: Text('Added your usuals — ready to review.')),
          ],
        ),
      ),
    );
  }
}

class _HeroArea extends StatelessWidget {
  const _HeroArea({required this.data, required this.onAiPressed});

  final HomeDashboardData data;
  final VoidCallback onAiPressed;

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveMetrics.of(context);
    if (!metrics.isExpanded) return AiRequestCard(onTap: onAiPressed);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: AiRequestCard(onTap: onAiPressed)),
        const SizedBox(width: 18),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Happening now', action: 'View order'),
              const SizedBox(height: 13),
              ActiveOrderCard(order: data.activeOrder),
            ],
          ),
        ),
      ],
    );
  }
}

class ServiceSheet extends StatelessWidget {
  const ServiceSheet({super.key, required this.service});

  final ServiceCategory service;

  @override
  Widget build(BuildContext context) => _SheetSurface(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ModalTopBar(),
        const SizedBox(height: 22),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(23),
          ),
          child: Icon(service.icon, size: 31),
        ),
        const SizedBox(height: 15),
        Text(service.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '${service.detail} · Smart preferences applied',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              'Start ${service.name.toLowerCase()} order',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class AiPromptSheet extends StatefulWidget {
  const AiPromptSheet({super.key});

  @override
  State<AiPromptSheet> createState() => _AiPromptSheetState();
}

class _AiPromptSheetState extends State<AiPromptSheet> {
  final TextEditingController _controller = TextEditingController();

  static const prompts = [
    'Repeat last grocery',
    'Plan dinner for 4',
    'Pickup my laundry',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _SheetSurface(
        dark: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ModalTopBar(dark: true),
            const SizedBox(height: 21),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppColors.yellow),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'What should I handle?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use everyday language. I’ll plan the services, timing and checkout for you.',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.58),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prompts
                  .map(
                    (prompt) => _PromptChip(
                      label: prompt,
                      onTap: () => setState(() => _controller.text = prompt),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 17),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              style: const TextStyle(color: AppColors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tell JabChaho what you need…',
                hintStyle: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.35),
                ),
                filled: true,
                fillColor: AppColors.white.withValues(alpha: 0.09),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.black,
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) => LiquidGlass(
    dark: dark,
    opacity: dark ? 0.94 : 0.88,
    blur: 30,
    radius: 30,
    shadowOpacity: 0.18,
    variant: GlassVariant.prominent,
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.paddingOf(context).bottom + 20,
    ),
    child: child,
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: dark
          ? AppColors.white.withValues(alpha: 0.25)
          : AppColors.black.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _ModalTopBar extends StatelessWidget {
  const _ModalTopBar({this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (!AdaptiveMetrics.of(context).isExpanded) {
      return Center(child: _SheetHandle(dark: dark));
    }

    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Close',
        style: IconButton.styleFrom(
          backgroundColor: dark
              ? AppColors.white.withValues(alpha: 0.09)
              : AppColors.black.withValues(alpha: 0.05),
          foregroundColor: dark ? AppColors.white : AppColors.black,
        ),
        icon: const Icon(Icons.close_rounded, size: 20),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white.withValues(alpha: 0.09),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: AppColors.white.withValues(alpha: 0.15)),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
