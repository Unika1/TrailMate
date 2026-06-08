import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailmate/core/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/trek_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: TrailMateApp()));
}

class TrailMateApp extends ConsumerStatefulWidget {
  const TrailMateApp({super.key});

  @override
  ConsumerState<TrailMateApp> createState() => _TrailMateAppState();
}

class _TrailMateAppState extends ConsumerState<TrailMateApp> {
  @override
  void initState() {
    super.initState();
    // Load persisted auth token and saved routes on startup
    Future.microtask(() async {
      await ref.read(authProvider).loadFromStorage();
      if (ref.read(authProvider).isLoggedIn) {
        await ref.read(trekProvider).loadSavedRoutes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrailMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
