import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../home/data/static_home_repository.dart';
import '../../home/presentation/home_page.dart';

@immutable
class AppDestination {
  const AppDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

final class NavigationController extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void select(int index) {
    if (_index == index) return;
    _index = index;
    HapticFeedback.selectionClick();
    notifyListeners();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final NavigationController _controller = NavigationController();
  final _repository = const StaticHomeRepository();

  static const _destinations = [
    AppDestination(label: 'Home', icon: Icons.home_rounded),
    AppDestination(label: 'Orders', icon: Icons.receipt_long_rounded),
    AppDestination(label: 'Services', icon: Icons.grid_view_rounded),
    AppDestination(label: 'You', icon: Icons.person_rounded),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final metrics = AdaptiveMetrics.of(context);
        final pages = [
          HomePage(repository: _repository),
          const EmptyDestination(
            icon: Icons.receipt_long_rounded,
            title: 'Your orders',
            message: 'Every service, tracked in one calm place.',
          ),
          const EmptyDestination(
            icon: Icons.grid_view_rounded,
            title: 'All services',
            message: 'Everything you need, whenever you need it.',
          ),
          const EmptyDestination(
            icon: Icons.person_rounded,
            title: 'Your space',
            message: 'Preferences, addresses, payments and smart routines.',
          ),
        ];

        return Scaffold(
          extendBody: !metrics.isExpanded,
          body: Row(
            children: [
              if (metrics.isExpanded)
                _AdaptiveRail(
                  destinations: _destinations,
                  selectedIndex: _controller.index,
                  onSelected: _controller.select,
                ),
              Expanded(
                child: IndexedStack(index: _controller.index, children: pages),
              ),
            ],
          ),
          bottomNavigationBar: metrics.isExpanded
              ? null
              : _GlassBottomNavigation(
                  destinations: _destinations,
                  selectedIndex: _controller.index,
                  onSelected: _controller.select,
                ),
        );
      },
    );
  }
}

class _GlassBottomNavigation extends StatelessWidget {
  const _GlassBottomNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: LiquidGlass(
        radius: 26,
        blur: 30,
        opacity: 0.72,
        padding: const EdgeInsets.all(4),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: SizedBox(
            height: 58,
            child: Row(
              children: List.generate(destinations.length, (index) {
                final item = destinations[index];
                return Expanded(
                  child: _DestinationButton(
                    destination: item,
                    selected: selectedIndex == index,
                    onTap: () => onSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? AppColors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                destination.icon,
                size: 20,
                color: selected
                    ? AppColors.yellow
                    : AppColors.black.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.white
                      : AppColors.black.withValues(alpha: 0.46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdaptiveRail extends StatelessWidget {
  const _AdaptiveRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LiquidGlass(
          radius: 28,
          opacity: 0.64,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: NavigationRail(
            backgroundColor: Colors.transparent,
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            labelType: NavigationRailLabelType.all,
            leading: const _RailBrand(),
            destinations: destinations
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, color: AppColors.yellow),
                    label: Text(item.label),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _RailBrand extends StatelessWidget {
  const _RailBrand();

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    margin: const EdgeInsets.only(bottom: 24),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Text(
      'J',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
    ),
  );
}

class EmptyDestination extends StatelessWidget {
  const EmptyDestination({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AdaptiveCenter(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 31),
              ),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppColors.muted),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
