import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single shared SupabaseClient. Repositories accept this via [Ref.read] so
/// they can be overridden in tests with `ProviderScope(overrides: [...])`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth state stream from Supabase. Used purely as an *invalidation trigger*
/// for [sessionProvider] — never read directly by widgets.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Synchronous current session.
///
/// Two-step pattern: `authStateChangesProvider` triggers re-evaluation,
/// this provider returns `client.auth.currentSession` (the persisted source
/// of truth). Avoids the cold-start "flash to logged out" that pure stream
/// reads suffer from.
final sessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateChangesProvider);
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentSession;
});
