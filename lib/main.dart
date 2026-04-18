import 'package:flutter/material.dart';
import 'package:micathon/screens/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:micathon/screens/login0.dart';
import 'package:micathon/screens/parent_home1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gopjyaqryeppewlpbugf.supabase.co',
    anonKey: 'sb_publishable_rXETj8P-2B_t6cbK_pZo9Q_Wpi2BxgP',
  );

  runApp(const KafeelSignUpApp());
}

/// Top-level app that decides whether to show the login screen or the
/// authenticated home, based on the current Supabase auth session.
class MicathonApp extends StatelessWidget {
  const MicathonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafeel',
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, _) {
        final session = auth.currentSession;
        if (session == null) {
          return const KafeelLoginApp();
        }
        return const ParentHome();
      },
    );
  }
}
