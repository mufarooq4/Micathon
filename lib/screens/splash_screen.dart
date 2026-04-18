import 'package:flutter/material.dart';

/// Brand-coloured splash shown while the app is determining which destination
/// to route to (initial auth check, profile load, trigger-lag grace window).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _kBackground = Color(0xFFFAF9F6);
  static const Color _kPrimary = Color(0xFF00502C);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _kBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_kPrimary),
            ),
            SizedBox(height: 16),
            Text(
              'Kafeel',
              style: TextStyle(
                color: _kPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
