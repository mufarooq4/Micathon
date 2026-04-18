import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import 'realtime_utils.dart';

/// Reads of `public.profiles` rows OTHER than the caller's own (those go
/// through `ProfilesRepository.watchMe`).
///
/// Server-side RLS enforces family scoping — `profiles_family_select` only
/// returns rows that share the caller's `family_id`. The client never
/// passes a family_id; it just queries and trusts RLS.
class FamilyRepository {
  FamilyRepository(this._client);

  final SupabaseClient _client;

  /// Live stream of every profile in the caller's family (including the
  /// caller). Emits in name order. Re-emits on any insert/update/delete in
  /// that family because of `replica identity full`.
  Stream<List<Profile>> watchFamilyMembers(String familyId) {
    return resilientRealtimeStream(() => _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId)
        .order('full_name')
        .map((rows) => rows.map(Profile.fromMap).toList()));
  }
}
