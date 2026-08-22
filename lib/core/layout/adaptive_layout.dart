import 'package:flutter/material.dart';

enum WindowClass { compact, medium, expanded }

@immutable
class AdaptiveMetrics {
  const AdaptiveMetrics._({
    required this.windowClass,
    required this.gutter,
    required this.maxContentWidth,
    required this.serviceColumns,
    required this.bottomClearance,
  });

  factory AdaptiveMetrics.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final windowClass = switch (width) {
      < 600 => WindowClass.compact,
      < 1024 => WindowClass.medium,
      _ => WindowClass.expanded,
    };

    return AdaptiveMetrics._(
      windowClass: windowClass,
      gutter: switch (width) {
        < 360 => 16,
        < 700 => 20,
        _ => 28,
      },
      maxContentWidth: switch (windowClass) {
        WindowClass.compact => 620,
        WindowClass.medium => 840,
        WindowClass.expanded => 1120,
      },
      serviceColumns: switch (width) {
        < 350 => 3,
        < 600 => 4,
        < 850 => 5,
        < 1200 => 6,
        _ => 8,
      },
      bottomClearance: windowClass == WindowClass.expanded ? 40 : 128,
    );
  }

  final WindowClass windowClass;
  final double gutter;
  final double maxContentWidth;
  final int serviceColumns;
  final double bottomClearance;

  bool get isCompact => windowClass == WindowClass.compact;
  bool get isExpanded => windowClass == WindowClass.expanded;
}

class AdaptiveCenter extends StatelessWidget {
  const AdaptiveCenter({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final metrics = AdaptiveMetrics.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? metrics.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
