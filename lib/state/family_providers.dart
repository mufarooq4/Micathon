import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dependent_controls_repository.dart';
import '../data/family_repository.dart';
import '../data/requests_repository.dart';
import '../data/transactions_repository.dart';
import '../models/dependent_controls.dart';
import '../models/money_request.dart';
import '../models/profile.dart';
import '../models/transaction.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

/// Family / transactions / requests Riverpod graph.
///
/// IMPORTANT: every stream provider in here keys off ONLY the bits of the
/// profile it actually depends on (family_id and user id), via `.select`.
///
/// Watching the whole `myProfileProvider` would re-run the body on every
/// balance update, which would cancel and re-open the underlying Supabase
/// Realtime channels every single time money moved. After a few minutes of
/// normal use that produces a runaway churn of websocket channels and the
/// app eventually dies (OOM / dropped websocket / ANR). Always `.select`
/// the minimal key.

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(ref.watch(supabaseClientProvider));
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(supabaseClientProvider));
});

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  return RequestsRepository(ref.watch(supabaseClientProvider));
});

final dependentControlsRepositoryProvider =
    Provider<DependentControlsRepository>((ref) {
  return DependentControlsRepository(ref.watch(supabaseClientProvider));
});

/// Just the current user's family id. Re-emits ONLY when the id changes
/// (sign in/out, redeem invite, create family). Used as the stable key for
/// every family-scoped realtime stream below.
final _myFamilyIdProvider = Provider<String?>((ref) {
  return ref.watch(
    myProfileProvider.select((async) => async.asData?.value?.familyId),
  );
});

/// (familyId, userId) pair for streams that need both. Equality on Dart
/// records is structural, so `.select` correctly skips re-runs when neither
/// value changes.
final _familyAndUserIdProvider = Provider<(String?, String?)>((ref) {
  return ref.watch(
    myProfileProvider.select((async) {
      final p = async.asData?.value;
      return (p?.familyId, p?.id);
    }),
  );
});

/// Live list of every member of the current user's family. Empty when the
/// user has no family yet.
final familyMembersProvider = StreamProvider<List<Profile>>((ref) {
  final familyId = ref.watch(_myFamilyIdProvider);
  if (familyId == null) return Stream<List<Profile>>.value(const []);
  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchFamilyMembers(familyId);
});

/// Live family ledger (newest first). For parents this is the entire
/// family; for children RLS narrows it down to rows they're a party to.
final familyTransactionsProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final familyId = ref.watch(_myFamilyIdProvider);
  if (familyId == null) return Stream<List<LedgerEntry>>.value(const []);
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchVisibleTransactions(familyId);
});

/// Live "my transactions" — narrowed client-side to rows where the current
/// user is sender or receiver. Used by Child Activity (and useful for any
/// "Recent activity" peek on Parent screens).
final myTransactionsProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final (familyId, userId) = ref.watch(_familyAndUserIdProvider);
  if (familyId == null || userId == null) {
    return Stream<List<LedgerEntry>>.value(const []);
  }
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchOwnTransactions(familyId: familyId, userId: userId);
});

/// Live list of every request visible to the user (parents see all family
/// requests, children see their own only).
final familyRequestsProvider = StreamProvider<List<MoneyRequest>>((ref) {
  final familyId = ref.watch(_myFamilyIdProvider);
  if (familyId == null) return Stream<List<MoneyRequest>>.value(const []);
  final repo = ref.watch(requestsRepositoryProvider);
  return repo.watchVisibleRequests(familyId);
});

/// Pending requests where the current user is the chosen approver.
/// Used by Parent Home for the approve/decline card.
final myIncomingPendingRequestsProvider =
    StreamProvider<List<MoneyRequest>>((ref) {
  final (familyId, userId) = ref.watch(_familyAndUserIdProvider);
  if (familyId == null || userId == null) {
    return Stream<List<MoneyRequest>>.value(const []);
  }
  final repo = ref.watch(requestsRepositoryProvider);
  return repo.watchIncomingPending(familyId: familyId, parentId: userId);
});

/// Requests CREATED by the current user (any status). Used by Child Home
/// preview and the dependent_approval outbox screen.
final myOutgoingRequestsProvider =
    StreamProvider<List<MoneyRequest>>((ref) {
  final (familyId, userId) = ref.watch(_familyAndUserIdProvider);
  if (familyId == null || userId == null) {
    return Stream<List<MoneyRequest>>.value(const []);
  }
  final repo = ref.watch(requestsRepositoryProvider);
  return repo.watchOutgoing(familyId: familyId, userId: userId);
});

/// Force a fresh fetch of balances and family member rows.
///
/// We call this after any write that changes balances (transfer, approve a
/// request) because Supabase Realtime UPDATE events on `public.profiles`
/// only deliver if Realtime is enabled for the table AND the table has
/// `REPLICA IDENTITY FULL`. If either is missing, `.stream()` will sit on
/// stale rows forever. Invalidating these two providers triggers a fresh
/// SELECT through the same stream subscription path, so the user sees the
/// new balance immediately whether Realtime is wired up or not.
void refreshBalancesAndMembers(WidgetRef ref) {
  ref.invalidate(myProfileProvider);
  ref.invalidate(familyMembersProvider);
}

/// Same idea for request-list screens after create / approve / decline /
/// cancel actions.
void refreshRequests(WidgetRef ref) {
  ref.invalidate(familyRequestsProvider);
  ref.invalidate(myIncomingPendingRequestsProvider);
  ref.invalidate(myOutgoingRequestsProvider);
}

// ---------------------------------------------------------------------------
// Parental controls (per-child allowance + auto-transfer schedule).
// ---------------------------------------------------------------------------

/// Live `dependent_controls` row for a single child. Emits `null` when no
/// row has ever been written (i.e. the parent hasn't opened the controls
/// for this child yet).
///
/// Same `.select` discipline as everything else in this file: it keys off
/// `_myFamilyIdProvider`, never `myProfileProvider` directly, so balance
/// updates don't tear the channel down.
final dependentControlsProvider =
    StreamProvider.family<DependentControls?, String>((ref, childId) {
  final familyId = ref.watch(_myFamilyIdProvider);
  if (familyId == null) return Stream<DependentControls?>.value(null);
  final repo = ref.watch(dependentControlsRepositoryProvider);
  return repo.watch(familyId: familyId, childId: childId);
});

/// Recent OUTGOING transactions for an arbitrary user in the caller's
/// family — used by the "Recent Spending" card on the parent's view of a
/// child. Limited to the most recent 5 by default.
///
/// Reuses the existing `familyTransactionsProvider` stream (so we don't
/// open a second realtime channel for the same table) and filters in
/// memory. RLS already guarantees we only see rows we're allowed to.
final recentSpendingProvider =
    StreamProvider.family<List<LedgerEntry>, String>((ref, userId) {
  final familyId = ref.watch(_myFamilyIdProvider);
  if (familyId == null) return Stream<List<LedgerEntry>>.value(const []);
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchVisibleTransactions(familyId).map(
        (all) => all.where((t) => t.senderId == userId).take(5).toList(),
      );
});

/// Force-refresh the dependent controls for [childId] after a successful
/// upsert. Same belt-and-braces approach as `refreshBalancesAndMembers` —
/// works whether or not realtime UPDATE payloads are wired up correctly
/// for the new table.
void refreshDependentControls(WidgetRef ref, String childId) {
  ref.invalidate(dependentControlsProvider(childId));
}
