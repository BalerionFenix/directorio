import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';

void main() {
  usePathUrlStrategy(); // URLs limpias: /contacts/7 en vez de /#/contacts/7
  runApp(const DirectorioApp());
}

class DirectorioApp extends StatelessWidget {
  /// Solo las pruebas pasan otro router; la app usa [appRouter].
  final GoRouter? router;

  const DirectorioApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      routerConfig: router ?? appRouter,
    );
  }
}
