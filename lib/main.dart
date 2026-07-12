import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/local/seed_loader.dart';
import 'presentation/providers/repository_providers.dart';
import 'presentation/providers/theme_mode_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MiApp()));
}

class MiApp extends ConsumerStatefulWidget {
  const MiApp({super.key});

  @override
  ConsumerState<MiApp> createState() => _MiAppState();
}

class _MiAppState extends ConsumerState<MiApp> {
  @override
  void initState() {
    super.initState();
    // Populate the database from the Obsidian export on first run only;
    // seedDatabaseIfEmpty is a no-op once there's at least one restaurant.
    Future.microtask(() => seedDatabaseIfEmpty(
          restaurantes: ref.read(restauranteRepositoryProvider),
          platos: ref.read(platoRepositoryProvider),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodLog',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider).value ?? ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
