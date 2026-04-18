import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/invitation.dart';
import '../models/profile.dart';

/// Wraps the invitation-related Postgres RPCs (`create_invitation` and
/// `redeem_invitation`).
///
/// We do not currently expose any direct reads / writes against the
/// `public.invitations` table from the client — all access goes through
/// security-definer functions so the server can enforce the
/// "only parents in a family can invite" / "only pending users can redeem"
/// invariants.
class InvitationsRepository {
  InvitationsRepository(this._client);

  final SupabaseClient _client;

  /// Generates a fresh invitation code for the caller's family.
  ///
  /// Throws [PostgrestException] on validation failure. SQLSTATEs of note:
  ///   - `28000` → caller is not authenticated
  ///   - `42501` → caller is not a parent in a family
  ///   - `22023` → bad role / TTL argument
  ///   - `40001` → exhausted code-generation retries (vanishingly rare)
  Future<Invitation> createInvitation({
    required UserRole roleOffered,
    Duration ttl = const Duration(hours: 24),
  }) async {
    if (roleOffered != UserRole.child && roleOffered != UserRole.parent) {
      throw ArgumentError.value(
        roleOffered,
        'roleOffered',
        'Must be child or parent',
      );
    }
    final ttlHours = ttl.inHours.clamp(1, 24 * 30);
    final result = await _client.rpc(
      'create_invitation',
      params: {
        'p_role_offered': roleOffered.name,
        'p_ttl_hours': ttlHours,
      },
    );
    // The function returns SETOF (id, code, role_offered, expires_at), which
    // PostgREST surfaces as a one-row list.
    final rows = (result as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) {
      throw StateError('create_invitation returned no rows');
    }
    return Invitation.fromMap(rows.first);
  }

  /// Redeem an invitation code and join the corresponding family.
  ///
  /// On success, returns the joined family's UUID. The caller's profile row
  /// will have been updated server-side; the streamed `myProfileProvider` will
  /// see the new `role` and `family_id` and re-route automatically.
  ///
  /// Throws [PostgrestException] on validation failure. SQLSTATE codes worth
  /// branching on:
  ///   - `P0002` → invalid code
  ///   - `22023` → already used / already onboarded / expired
  ///   - `28000` → not authenticated
  Future<String> redeemInvitation(String code) async {
    final result = await _client.rpc(
      'redeem_invitation',
      params: {'p_code': Invitation.normaliseCode(code)},
    );
    return result as String;
  }
}
