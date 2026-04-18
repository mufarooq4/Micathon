import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/money_request.dart';

/// Reads of `public.requests` and the `create_request` / `act_on_request`
/// RPCs. All visibility flows through the `requests_family_select` RLS
/// policy.
class RequestsRepository {
  RequestsRepository(this._client);

  final SupabaseClient _client;

  /// Newest-first stream of every request visible to the caller in the
  /// family. Parents see all family requests, children only see ones
  /// they're a party to (per RLS).
  Stream<List<MoneyRequest>> watchVisibleRequests(String familyId) {
    return _client
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(MoneyRequest.fromMap).toList());
  }

  /// Pending requests directed at [parentId] (the parent who needs to
  /// approve). Used by the Parent Home approval card.
  Stream<List<MoneyRequest>> watchIncomingPending({
    required String familyId,
    required String parentId,
  }) {
    return watchVisibleRequests(familyId).map(
      (all) => all
          .where(
            (r) => r.isPending && r.approverId == parentId,
          )
          .toList(),
    );
  }

  /// Requests created BY [userId] (any status). Used by Child Home and the
  /// child's `dependent_approval` outbox screen.
  Stream<List<MoneyRequest>> watchOutgoing({
    required String familyId,
    required String userId,
  }) {
    return watchVisibleRequests(familyId).map(
      (all) => all.where((r) => r.requesterId == userId).toList(),
    );
  }

  /// Create a new pending request. Returns the new request id.
  ///
  /// SQLSTATEs to expect:
  ///   - `22023` → bad amount / approver isn't a parent / approver not in family
  ///   - `42501` → caller has no family
  ///   - `28000` → not authenticated
  Future<String> createRequest({
    required String approverId,
    required BigInt amountMinor,
  }) async {
    final result = await _client.rpc(
      'create_request',
      params: {
        'p_approver_id': approverId,
        'p_amount': amountMinor.toInt(),
      },
    );
    return result as String;
  }

  /// Approve, decline, or cancel a request. The RPC handles all balance
  /// movement atomically (and writes a ledger row on approve).
  ///
  /// [action] must be `'approve'`, `'decline'`, or `'cancel'`.
  Future<void> actOnRequest({
    required String requestId,
    required String action,
  }) async {
    await _client.rpc(
      'act_on_request',
      params: {
        'p_request_id': requestId,
        'p_action': action,
      },
    );
  }
}
