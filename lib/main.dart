import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:micathon/models/app_destination.dart';
import 'package:micathon/screens/childhome5.dart';
import 'package:micathon/screens/login0.dart';
import 'package:micathon/screens/parent_home1.dart';
import 'package:micathon/screens/pending_invite_screen.dart';
import 'package:micathon/screens/signup.dart';
import 'package:micathon/screens/splash_screen.dart';
import 'package:micathon/state/auth_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/state/router_provider.dart';

const Color _kBackground = Color(0xFFFAF9F6);
const Color _kPrimary = Color(0xFF00502C);
const Color _kError = Color(0xFFBA1A1A);
const Color _kOnSurface = Color(0xFF1A1C1A);
const Color _kOnSurfaceVariant = Color(0xFF3F4941);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gopjyaqryeppewlpbugf.supabase.co',
    anonKey: 'sb_publishable_rXETj8P-2B_t6cbK_pZo9Q_Wpi2BxgP',
  );

  runApp(const ProviderScope(child: MicathonApp()));
}

/// Top-level app. The single MaterialApp owner; everything below is just a
/// home widget tree driven by the [routerProvider].
class MicathonApp extends StatelessWidget {
  const MicathonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafeel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _kBackground,
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: _kPrimary),
        useMaterial3: true,
      ),
      home: const _Router(),
    );
  }
}

/// Watches [routerProvider] and renders the matching destination.
///
/// All onboarding state machinery lives in providers — this widget is a pure
/// switch over the derived [AppDestination]. When the streamed profile
/// updates (e.g. after `redeem_invitation` or `create_family`), the router
/// re-derives and we swap children automatically.
class _Router extends ConsumerWidget {
  const _Router();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(routerProvider);
    return switch (destination) {
      UnauthDestination() => const _UnauthFlow(),
      SplashDestination() => const SplashScreen(),
      PendingInviteDestination() => const PendingInviteScreen(),
      ParentHomeDestination() => const ParentHome(),
      ChildHomeDestination() => const ChildHome(),
      ProfileErrorDestination(message: final msg) => _RoleErrorScreen(
          message: msg,
          onRetry: () => ref.invalidate(myProfileProvider),
          onSignOut: () =>
              ref.read(supabaseClientProvider).auth.signOut(),
        ),
    };
  }
}

/// Unauthenticated flow: hosts the Login and SignUp screens and toggles
/// between them in place. Critically, this does NOT use
/// `Navigator.pushReplacement` at the router level — that would tear out the
/// router widget tree and prevent the auth provider from swapping in the
/// authed UI on a successful sign-in.
class _UnauthFlow extends StatefulWidget {
  const _UnauthFlow();

  @override
  State<_UnauthFlow> createState() => _UnauthFlowState();
}

class _UnauthFlowState extends State<_UnauthFlow> {
  bool _showLogin = true;

  void _toggle() => setState(() => _showLogin = !_showLogin);

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen(onSignUpTap: _toggle);
    }
    return SignUpScreen(onLoginTap: _toggle);
  }
}

class _RoleErrorScreen extends StatelessWidget {
  const _RoleErrorScreen({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.error_outline, size: 64, color: _kError),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kOnSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _kOnSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: _kPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Sign out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
