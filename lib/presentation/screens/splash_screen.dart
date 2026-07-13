import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'home_screen.dart';

/// Brief branded splash shown right after Flutter's first frame.
///
/// Android 12+'s native splash screen API only supports a small icon inside
/// a masked circle, with no room for the "FoodLog" wordmark — so on those
/// devices the OS splash shows the icon alone. This widget shows the icon
/// plus the app name as real text for a moment before handing off to
/// [HomeScreen], keeping the branding consistent across every Android version.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>()?.accent ?? AppTheme.brandOrange;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/branding/icon.png', width: 160, height: 160),
            const SizedBox(height: 16),
            Text(
              'FoodLog',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
