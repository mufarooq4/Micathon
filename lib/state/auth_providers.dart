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
/// Prefers the session attached to the most recent auth-state event because
/// `client.auth.currentSession` can momentarily return the previous session
/// after `signOut()` in some supabase_flutter versions — which would leave
/// the router on the authed home with a null profile (the "3 dots after
/// sign out" bug). At cold start, before any event has fired, we fall back
/// to `currentSession` so a user with a persisted refresh token doesn't
/// flash through the unauth flow.
final sessionProvider = Provider<Session?>((ref) {
  final stateAsync = ref.watch(authStateChangesProvider);
  return stateAsync.when(
    data: (state) => state.session,
    loading: () => ref.read(supabaseClientProvider).auth.currentSession,
    error: (_, __) => null,
  );
});
