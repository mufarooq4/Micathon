import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/invitations_repository.dart';
import '../data/profiles_repository.dart';
import '../models/profile.dart';
import 'auth_providers.dart';

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  return ProfilesRepository(ref.watch(supabaseClientProvider));
});

final invitationsRepositoryProvider = Provider<InvitationsRepository>((ref) {
  return InvitationsRepository(ref.watch(supabaseClientProvider));
});

/// Live profile for the currently signed-in user.
///
/// - When there is no session: emits `null` synchronously.
/// - When there is a session: subscribes to the `profiles` row keyed by
///   `auth.uid()` via Supabase Realtime. Emits `null` while the row is
///   missing (the brief AFTER INSERT trigger lag).
///
/// This is THE source of truth for the user's role and family_id. Every
/// screen that needs profile data should `ref.watch(myProfileProvider)`
/// rather than rolling its own fetch.
final myProfileProvider = StreamProvider<Profile?>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return Stream<Profile?>.value(null);
  }
  final repo = ref.watch(profilesRepositoryProvider);
  return repo.watchMe(session.user.id);
});
