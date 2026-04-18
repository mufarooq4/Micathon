import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dependent_controls.dart';

/// Reads of `public.dependent_controls` and the `upsert_dependent_controls`
/// RPC. RLS gates writes to parents in the same family; SELECT is allowed
/// for any family member so children can see their own current limits and
/// schedule.
class DependentControlsRepository {
  DependentControlsRepository(this._client);

  final SupabaseClient _client;

  /// Live single-row stream for the (familyId, childId) pair.
  ///
  /// Emits `null` when no row exists yet (the parent has never opened the
  /// controls UI for this child). Emits the row on every UPDATE because
  /// the table is in `supabase_realtime` with `replica identity full`.
  ///
  /// Implementation note: supabase_flutter's `.stream()` only accepts a
  /// single `.eq()` filter cleanly, so we filter on `family_id` server-side
  /// and pick out the matching `child_id` client-side. Family sizes are
  /// small (a handful of children), so the over-fetch is negligible.
  Stream<DependentControls?> watch({
    required String familyId,
    required String childId,
  }) {
    return _client
        .from('dependent_controls')
        .stream(primaryKey: ['family_id', 'child_id'])
        .eq('family_id', familyId)
        .map((rows) {
      for (final row in rows) {
        if (row['child_id'] == childId) {
          return DependentControls.fromMap(row);
        }
      }
      return null;
    });
  }

  /// Create or update the controls row for [childId]. The caller MUST be a
  /// parent in the same family; the RPC enforces this server-side.
  ///
  /// SQLSTATEs to expect:
  ///   - `28000` → not authenticated
  ///   - `42501` → caller isn't a parent in this family
  ///   - `22023` → bad amount / day-of-week / target isn't a child
  Future<void> upsert({
    required String childId,
    BigInt? monthlyLimitMinor,
    required bool autoTransferEnabled,
    BigInt? autoTransferAmountMinor,
    int? autoTransferDay,
  }) async {
    await _client.rpc(
      'upsert_dependent_controls',
      params: {
        'p_child_id': childId,
        'p_monthly_limit_minor': monthlyLimitMinor?.toInt(),
        'p_auto_transfer_enabled': autoTransferEnabled,
        'p_auto_transfer_amount_minor': autoTransferAmountMinor?.toInt(),
        'p_auto_transfer_day': autoTransferDay,
      },
    );
  }
}
