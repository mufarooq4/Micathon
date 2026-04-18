import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

/// All Supabase access for the `public.profiles` table goes through here.
///
/// Screens never read `Supabase.instance.client` directly. They depend on
/// providers exposed in `lib/state/profile_providers.dart`, which in turn
/// delegate to this class.
class ProfilesRepository {
  ProfilesRepository(this._client);

  final SupabaseClient _client;

  /// Live stream of the signed-in user's profile row.
  ///
  /// Emits `null` while the row doesn't exist yet (handle_new_user trigger
  /// race window) and a populated [Profile] once the row appears or updates.
  ///
  /// Closes implicitly when the caller cancels the subscription.
  Stream<Profile?> watchMe(String userId) {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) {
      if (rows.isEmpty) return null;
      return Profile.fromMap(rows.first);
    });
  }

  /// One-shot fallback fetch used by the splash race-window logic.
  ///
  /// Returns `null` if the row hasn't been inserted yet.
  Future<Profile?> fetchMeOnce(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromMap(row);
  }

  /// Calls the `create_family(p_name)` Postgres RPC.
  ///
  /// Throws [PostgrestException] on RLS / invariant violations. The caller is
  /// expected to map the SQLSTATE on `e.code` to a user-facing message.
  Future<String> createFamily(String name) async {
    final result = await _client.rpc(
      'create_family',
      params: {'p_name': name},
    );
    return result as String;
  }
}
