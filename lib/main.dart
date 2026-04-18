import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:micathon/screens/signup.dart';
import 'package:micathon/screens/login0.dart';
import 'package:micathon/screens/parent_home1.dart';
import 'package:micathon/screens/childhome5.dart';

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

  runApp(const MicathonApp());
}

/// Top-level app that decides whether to show the sign-up/login screens or
/// the role-specific home, based on the current Supabase auth session.
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
          return const _UnauthFlow();
        }
        return const _RoleRouter();
      },
    );
  }
}

/// Unauthenticated flow: hosts the Sign Up and Login screens and toggles
/// between them in place. Critically, this does NOT use Navigator.pushReplacement
/// at the AuthGate level — that would tear out the AuthGate's home route and
/// prevent the auth state listener from swapping in the authed UI.
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

/// Looks up the signed-in user's role via the `me` view and routes them to
/// the appropriate home screen.
class _RoleRouter extends StatefulWidget {
  const _RoleRouter();

  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  late Future<String?> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _fetchRole();
  }

  Future<String?> _fetchRole() async {
    final client = Supabase.instance.client;
    final data = await client.from('me').select('role').maybeSingle();
    if (data == null) return null;
    return data['role'] as String?;
  }

  void _retry() {
    setState(() {
      _roleFuture = _fetchRole();
    });
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: _kBackground,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_kPrimary),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _RoleErrorScreen(
            message: snapshot.hasError
                ? 'Could not load your profile.\n${snapshot.error}'
                : 'No profile found for this account.',
            onRetry: _retry,
            onSignOut: _signOut,
          );
        }

        final role = snapshot.data;
        if (role == 'parent') {
          return const ParentHome();
        }
        return const ChildHome();
      },
    );
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
