import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/family_repository.dart';
import '../data/requests_repository.dart';
import '../data/transactions_repository.dart';
import '../models/money_request.dart';
import '../models/profile.dart';
import '../models/transaction.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

/// Family / transactions / requests Riverpod graph.
///
/// Everything here keys off the SAME `myProfileProvider` so that when the
/// router transitions a user from `pending` → onboarded (family_id appears)
/// the dependent streams immediately wake up and start emitting. Likewise
/// on sign-out they all collapse to empty/null.

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(ref.watch(supabaseClientProvider));
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(supabaseClientProvider));
});

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  return RequestsRepository(ref.watch(supabaseClientProvider));
});

/// Live list of every member of the current user's family. Empty when the
/// user has no family yet.
final familyMembersProvider = StreamProvider<List<Profile>>((ref) {
  final profileAsync = ref.watch(myProfileProvider);
  final familyId = profileAsync.asData?.value?.familyId;
  if (familyId == null) return Stream<List<Profile>>.value(const []);
  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchFamilyMembers(familyId);
});

/// Live family ledger (newest first). For parents this is the entire
/// family; for children RLS narrows it down to rows they're a party to.
final familyTransactionsProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final profileAsync = ref.watch(myProfileProvider);
  final familyId = profileAsync.asData?.value?.familyId;
  if (familyId == null) return Stream<List<LedgerEntry>>.value(const []);
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchVisibleTransactions(familyId);
});

/// Live "my transactions" — narrowed client-side to rows where the current
/// user is sender or receiver. Used by Child Activity (and useful for any
/// "Recent activity" peek on Parent screens).
final myTransactionsProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final profile = ref.watch(myProfileProvider).asData?.value;
  if (profile?.familyId == null) {
    return Stream<List<LedgerEntry>>.value(const []);
  }
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchOwnTransactions(
    familyId: profile!.familyId!,
    userId: profile.id,
  );
});

/// Live list of every request visible to the user (parents see all family
/// requests, children see their own only).
final familyRequestsProvider = StreamProvider<List<MoneyRequest>>((ref) {
  final profile = ref.watch(myProfileProvider).asData?.value;
  if (profile?.familyId == null) {
    return Stream<List<MoneyRequest>>.value(const []);
  }
  final repo = ref.watch(requestsRepositoryProvider);
  return repo.watchVisibleRequests(profile!.familyId!);
});

/// Pending requests where the current user is the chosen approver.
/// Used by Parent Home for the approve/decline card.
final myIncomingPendingRequestsProvider =
    StreamProvider<List<MoneyRequest>>((ref) {
  final profile = ref.watch(myProfileProvider).asData?.value;
  if (profile?.familyId == null) {
    return Stream<List<MoneyRequest>>.value(const []);
  }
  final repo = ref.watch(requestsRepositoryProvider);
  return repo.watchIncomingPending(
    familyId: profile!.familyId!,
    parentId: profile.id,
  );
});

/// Requests CREATED by the current user (any status). Used by Child Home
/// preview and the dependent_approval outbox screen.
final myOutgoingRequestsProvider =
    StreamProvider<List<MoneyRequest>>((ref) {
  final profile = ref.watch(myProfileProvider).asData?.value;
  if (profile?.familyId == null) {
    return Stream<List<MoneyRequest>>.value(const []);
  }
  final repo = ref.watch(requestsRepositoryProvider);
  return repo.watchOutgoing(
    familyId: profile!.familyId!,
    userId: profile.id,
  );
});
