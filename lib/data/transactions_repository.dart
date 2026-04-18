import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction.dart';

/// Reads of `public.transactions` and the `transfer_money` RPC.
///
/// All visibility is governed by the `transactions_family_select` RLS
/// policy: parents see every row in their family; children only see rows
/// they're a party to.
class TransactionsRepository {
  TransactionsRepository(this._client);

  final SupabaseClient _client;

  /// Newest-first stream of every visible transaction in the family.
  ///
  /// For a parent this is the entire family ledger; for a child this is
  /// just their own personal flow (RLS does the filtering).
  Stream<List<LedgerEntry>> watchVisibleTransactions(String familyId) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(LedgerEntry.fromMap).toList());
  }

  /// Newest-first stream of transactions where [userId] is either sender
  /// or receiver. Useful for the Child Activity screen and the Parent's
  /// "my own activity" peek.
  ///
  /// Note: Supabase realtime `.stream()` doesn't support `or(...)` filters
  /// natively, so we fall back to the family stream and filter client-side.
  /// That's safe because RLS already restricts what we can see.
  Stream<List<LedgerEntry>> watchOwnTransactions({
    required String familyId,
    required String userId,
  }) {
    return watchVisibleTransactions(familyId).map(
      (all) => all
          .where((t) => t.senderId == userId || t.receiverId == userId)
          .toList(),
    );
  }

  /// Atomic transfer via the `transfer_money` security-definer RPC.
  /// Returns the resulting transaction id.
  ///
  /// Throws [PostgrestException] on validation failure. SQLSTATEs:
  ///   - `28000` → not authenticated
  ///   - `22023` → bad amount / sending to self / insufficient balance
  ///   - `42501` → cross-family or no family
  ///   - `P0002` → receiver profile not found
  Future<String> transferMoney({
    required String receiverId,
    required BigInt amountMinor,
  }) async {
    final result = await _client.rpc(
      'transfer_money',
      params: {
        'p_receiver_id': receiverId,
        // PostgREST encodes BigInt safely if we send it as a string for
        // values that exceed JS's 2^53 safe range. For our paisa amounts
        // (well within int64 but also well within 2^53) sending as int is
        // fine; .toInt() preserves the value losslessly here.
        'p_amount': amountMinor.toInt(),
      },
    );
    return result as String;
  }
}
