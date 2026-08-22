import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/presentation/home_shell.dart';

class JabChahoApp extends StatelessWidget {
  const JabChahoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JabChaho',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
      home: const HomeShell(),
    );
  }
}
