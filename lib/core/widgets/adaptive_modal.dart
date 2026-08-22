import 'package:flutter/material.dart';

import '../layout/adaptive_layout.dart';

abstract final class AdaptiveModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double maxWidth = 620,
  }) {
    if (AdaptiveMetrics.of(context).isExpanded) {
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.48),
        builder: (dialogContext) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: MediaQuery.sizeOf(dialogContext).height - 80,
            ),
            child: builder(dialogContext),
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: maxWidth),
      builder: builder,
    );
  }
}
