import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/dependent_controls.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/money_request.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/models/transaction.dart';
import 'package:micathon/screens/Monereq13.dart';
import 'package:micathon/screens/Sendmoney12.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/avatar_utils.dart';

class AppColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color primary = Color(0xFF00502C);
  static const Color primaryFixed = Color(0xFF9DF6B9);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F1);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC4E9CC);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);
}

/// Profile screen for a single family member. Shows ledger history filtered
/// to transactions between [member] and the current user, plus the requests
/// shared between them. Send/Request buttons are gated by relationship: any
/// family member can be sent money; only parents can be a request approver.
class FamilyMemberProfileScreen extends ConsumerStatefulWidget {
  const FamilyMemberProfileScreen({super.key, required this.member});

  final Profile member;

  @override
  ConsumerState<FamilyMemberProfileScreen> createState() =>
      _FamilyMemberProfileScreenState();
}

class _FamilyMemberProfileScreenState
    extends ConsumerState<FamilyMemberProfileScreen> {
  // 0 = Transactions, 1 = Requests
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myProfileProvider).asData?.value;
    final txAsync = ref.watch(familyTransactionsProvider);
    final reqAsync = ref.watch(familyRequestsProvider);

    // Parental controls only make sense when the *viewer* is a parent and
    // the *target* is a child. Children peeking at a sibling's profile see
    // recent spending only.
    final showControls = me != null &&
        me.role == UserRole.parent &&
        widget.member.role == UserRole.child &&
        me.familyId != null &&
        me.familyId == widget.member.familyId;

    final showRecentSpending = widget.member.role == UserRole.child;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(me),
              if (showControls) ...[
                const SizedBox(height: 24),
                _AllowanceCard(child: widget.member),
                const SizedBox(height: 16),
                _AutoTransferCard(child: widget.member),
              ],
              if (showRecentSpending) ...[
                const SizedBox(height: 16),
                _RecentSpendingCard(child: widget.member),
              ],
              const SizedBox(height: 32),
              _buildCustomTabBar(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTabIndex == 0
                    ? _buildTransactionsTab(me, txAsync)
                    : _buildRequestsTab(me, reqAsync),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background.withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 24,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text('Kafeel',
          style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5)),
    );
  }

  Widget _buildProfileHeader(Profile? me) {
    final color = AvatarUtils.colorFor(widget.member.id);
    final initial = AvatarUtils.initial(widget.member.fullName);
    final canRequest =
        widget.member.role == UserRole.parent && me?.id != widget.member.id;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryFixed, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.member.fullName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _roleLabel(widget.member.role).toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => SendMoneyScreen(
                          initialRecipient: widget.member,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text('Send',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canRequest
                      ? () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => RequestMoneyScreen(
                                initialApprover: widget.member,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.call_received, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.surfaceContainerHighest,
                    foregroundColor: AppColors.onSurface,
                    disabledBackgroundColor:
                        AppColors.surfaceContainerHighest.withOpacity(0.4),
                    disabledForegroundColor:
                        AppColors.onSurfaceVariant.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text('Request',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Transactions', 0)),
          Expanded(child: _buildTabButton('Requests', 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color:
                isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(
      Profile? me, AsyncValue<List<LedgerEntry>> txAsync) {
    // Parents viewing one of their children get a wider view: every
    // transaction the child was part of, not just the ones with the
    // viewing parent. This matches the parental-controls model — parents
    // need full visibility into a child's spending. RLS already returns
    // every family transaction to a parent, so no provider changes needed.
    final showAll = me?.role == UserRole.parent &&
        widget.member.role == UserRole.child &&
        me?.familyId != null &&
        me?.familyId == widget.member.familyId;
    final family =
        ref.watch(familyMembersProvider).asData?.value ?? const <Profile>[];

    return Column(
      key: const ValueKey('transactions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showAll
              ? '${widget.member.fullName}\'s activity'
              : 'History with ${widget.member.fullName}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        txAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              Text('Could not load: $e', style: const TextStyle(color: Colors.red)),
          data: (all) {
            final mine = me?.id ?? '';
            final filtered = all.where((t) {
              if (showAll) {
                return t.senderId == widget.member.id ||
                    t.receiverId == widget.member.id;
              }
              return (t.senderId == mine && t.receiverId == widget.member.id) ||
                  (t.senderId == widget.member.id && t.receiverId == mine);
            }).toList();
            if (filtered.isEmpty) {
              return _emptyTab(showAll
                  ? 'No activity for ${widget.member.fullName} yet.'
                  : 'No transactions with ${widget.member.fullName} yet.');
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    _txRow(filtered[i], mine,
                        showAll: showAll, family: family),
                    if (i < filtered.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(
                            color: AppColors.surfaceContainerLow, height: 1),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _txRow(LedgerEntry e, String meId,
      {bool showAll = false, List<Profile> family = const <Profile>[]}) {
    // When showAll, render from the child's perspective so the parent
    // reads "Sent to <sibling>" / "Received from <other parent>" instead
    // of being confused by viewer-relative wording.
    final perspectiveId = showAll ? widget.member.id : meId;
    final outgoing = e.isOutgoingFor(perspectiveId);
    final amount = outgoing
        ? '-${Money.format(e.amountMinor)}'
        : '+${Money.format(e.amountMinor)}';
    final String title;
    if (showAll) {
      final counterpartyId = e.counterpartyFor(perspectiveId);
      final counterpartyName = family
              .where((p) => p.id == counterpartyId)
              .map((p) => p.fullName)
              .firstOrNull ??
          'Family member';
      title = outgoing
          ? 'Sent to $counterpartyName'
          : 'Received from $counterpartyName';
    } else {
      title = outgoing
          ? 'Sent to ${widget.member.fullName}'
          : 'Received from ${widget.member.fullName}';
    }
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: outgoing
                ? AppColors.surfaceContainerHighest
                : AppColors.secondaryContainer.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            outgoing ? Icons.send : Icons.payments,
            color: outgoing ? AppColors.onSurfaceVariant : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.onSurface)),
              const SizedBox(height: 4),
              Text(_formatDate(e.createdAt),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: outgoing ? AppColors.onSurface : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab(
      Profile? me, AsyncValue<List<MoneyRequest>> reqAsync) {
    final showAll = me?.role == UserRole.parent &&
        widget.member.role == UserRole.child &&
        me?.familyId != null &&
        me?.familyId == widget.member.familyId;
    final family =
        ref.watch(familyMembersProvider).asData?.value ?? const <Profile>[];

    return Column(
      key: const ValueKey('requests'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Money Requests',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        reqAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Could not load: $e',
              style: const TextStyle(color: Colors.red)),
          data: (all) {
            final mine = me?.id ?? '';
            final filtered = all.where((r) {
              if (showAll) {
                return r.requesterId == widget.member.id ||
                    r.approverId == widget.member.id;
              }
              return (r.requesterId == mine &&
                      r.approverId == widget.member.id) ||
                  (r.requesterId == widget.member.id && r.approverId == mine);
            }).toList();
            if (filtered.isEmpty) {
              return _emptyTab(showAll
                  ? 'No requests for ${widget.member.fullName} yet.'
                  : 'No requests with ${widget.member.fullName} yet.');
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    _requestRow(filtered[i], mine,
                        showAll: showAll, family: family),
                    if (i < filtered.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(
                            color: AppColors.surfaceContainerLow, height: 1),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _requestRow(MoneyRequest r, String meId,
      {bool showAll = false, List<Profile> family = const <Profile>[]}) {
    // When showAll, the parent is auditing the child's request history,
    // so render from the child's perspective and resolve counterparties
    // from the family list.
    final perspectiveId = showAll ? widget.member.id : meId;
    final outgoing = r.requesterId == perspectiveId;
    final color = _statusColor(r.status);
    final amount = Money.format(r.amountMinor);

    String resolveName(String id) =>
        family
            .where((p) => p.id == id)
            .map((p) => p.fullName)
            .firstOrNull ??
        'Family member';

    final String label;
    if (showAll) {
      final childName = widget.member.fullName;
      if (outgoing) {
        // approverId is nullable on the model. The showAll filter only
        // surfaces rows where approverId matches the child id (non-null),
        // so this fallback is just type-safety, not a real code path.
        final approverName =
            r.approverId == null ? 'Family member' : resolveName(r.approverId!);
        label = '$childName requested $amount from $approverName';
      } else {
        final requesterName = resolveName(r.requesterId);
        label = '$requesterName requested $amount from $childName';
      }
    } else {
      label = outgoing
          ? 'You requested $amount'
          : '${widget.member.fullName} requested $amount';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            outgoing ? Icons.arrow_outward : Icons.arrow_downward,
            color: AppColors.onSurfaceVariant,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(_formatDate(r.createdAt),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyTab(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.child:
        return 'Child';
      case UserRole.pending:
        return 'Pending';
      case UserRole.unknown:
        return 'Member';
    }
  }

  Color _statusColor(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return Colors.amber.shade700;
      case RequestStatus.approved:
      case RequestStatus.executed:
        return AppColors.primary;
      case RequestStatus.declined:
      case RequestStatus.cancelled:
        return Colors.red.shade400;
      case RequestStatus.unknown:
        return AppColors.onSurfaceVariant;
    }
  }

  String _formatDate(DateTime ts) {
    final l = ts.toLocal();
    return '${l.day}/${l.month}/${l.year}';
  }
}

// ---------------------------------------------------------------------------
// Parental control cards.
//
// All three cards live inside this file (per spec — don't pull in the orphan
// manage_dependent4.dart). They are pure ConsumerWidgets that read from the
// new dependentControlsProvider / recentSpendingProvider streams; nothing
// here owns mutable state EXCEPT the slider, which uses a small stateful
// wrapper to debounce the upsert.
// ---------------------------------------------------------------------------

const Color _cardBg = AppColors.surfaceContainerLowest;
const Color _cardSurface = Color(0xFFF7F8F7);
const Color _greenAccent = AppColors.primary;
const Color _greenAccentBg = AppColors.primaryFixed;
const Color _textGrey = AppColors.onSurfaceVariant;

/// 0 ≤ value ≤ 10000 in Rs. (major units), rounded to nearest 100. Backed by
/// `BigInt` paisas in the database via `monthly_limit_minor`.
class _AllowanceCard extends ConsumerStatefulWidget {
  const _AllowanceCard({required this.child});
  final Profile child;

  @override
  ConsumerState<_AllowanceCard> createState() => _AllowanceCardState();
}

class _AllowanceCardState extends ConsumerState<_AllowanceCard> {
  /// Local "draft" value while the user is dragging. Synced to the
  /// provider's value whenever a new server value arrives AND the user
  /// isn't currently interacting.
  double? _draftMajor;
  bool _saving = false;
  bool _justSaved = false;
  String? _saveError;
  Timer? _debounce;
  Timer? _checkmarkClear;

  @override
  void dispose() {
    _debounce?.cancel();
    _checkmarkClear?.cancel();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _draftMajor = value;
      _saveError = null;
      _justSaved = false;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _flush);
  }

  Future<void> _flush() async {
    final draft = _draftMajor;
    if (draft == null) return;
    final repo = ref.read(dependentControlsRepositoryProvider);
    final current =
        ref.read(dependentControlsProvider(widget.child.id)).asData?.value;
    final limitMinor = BigInt.from(draft.round() * 100);

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await repo.upsert(
        childId: widget.child.id,
        monthlyLimitMinor: limitMinor,
        autoTransferEnabled: current?.autoTransferEnabled ?? false,
        autoTransferAmountMinor: current?.autoTransferAmountMinor,
        autoTransferDay: current?.autoTransferDay,
      );
      refreshDependentControls(ref, widget.child.id);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _justSaved = true;
      });
      _checkmarkClear?.cancel();
      _checkmarkClear = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justSaved = false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = _describeControlsError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dependentControlsProvider(widget.child.id));

    return _CardShell(
      child: async.when(
        loading: () => const _CardLoading(label: 'Budget & Limits'),
        error: (e, _) => _CardError(
          label: 'Budget & Limits',
          message: _describeControlsError(e),
        ),
        data: (controls) {
          // Default to Rs. 500 the first time the parent opens the card —
          // matches the manage_dependent4 mock.
          final serverMajor = (controls?.monthlyLimitMinor != null)
              ? (controls!.monthlyLimitMinor! ~/ BigInt.from(100)).toDouble()
              : 500.0;
          final draft = _draftMajor ?? serverMajor.clamp(0, 10000).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                icon: Icons.tune,
                title: 'Budget & Limits',
                trailing: _SaveIndicator(
                  saving: _saving,
                  justSaved: _justSaved,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MONTHLY ALLOWANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Rs. ${_formatRupeesWhole(draft.round())}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _greenAccent,
                  inactiveTrackColor: AppColors.surfaceContainerHighest,
                  thumbColor: Colors.white,
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10.0,
                    elevation: 4,
                  ),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: Slider(
                  value: draft,
                  min: 0,
                  max: 10000,
                  divisions: 100, // Rs. 100 increments at this scale
                  onChanged: _onSliderChanged,
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rs. 0',
                      style: TextStyle(color: _textGrey, fontSize: 12)),
                  Text('Rs. 10,000',
                      style: TextStyle(color: _textGrey, fontSize: 12)),
                ],
              ),
              if (_saveError != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: _saveError!),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AutoTransferCard extends ConsumerWidget {
  const _AutoTransferCard({required this.child});
  final Profile child;

  Future<void> _toggle(WidgetRef ref, BuildContext ctx, bool enabled,
      DependentControls? current) async {
    final repo = ref.read(dependentControlsRepositoryProvider);
    try {
      await repo.upsert(
        childId: child.id,
        monthlyLimitMinor: current?.monthlyLimitMinor,
        autoTransferEnabled: enabled,
        // Default to Rs. 50 every Saturday the first time it's enabled.
        autoTransferAmountMinor: enabled
            ? (current?.autoTransferAmountMinor ?? BigInt.from(5000))
            : current?.autoTransferAmountMinor,
        autoTransferDay:
            enabled ? (current?.autoTransferDay ?? 6) : current?.autoTransferDay,
      );
      refreshDependentControls(ref, child.id);
    } catch (e) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_describeControlsError(e)),
        ));
    }
  }

  Future<void> _openEditSheet(
      BuildContext ctx, WidgetRef ref, DependentControls? current) async {
    final result = await showModalBottomSheet<_EditScheduleResult>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => _EditScheduleSheet(
        initialAmountMinor:
            current?.autoTransferAmountMinor ?? BigInt.from(5000),
        initialDay: current?.autoTransferDay ?? 6,
      ),
    );
    if (result == null) return;

    final repo = ref.read(dependentControlsRepositoryProvider);
    try {
      await repo.upsert(
        childId: child.id,
        monthlyLimitMinor: current?.monthlyLimitMinor,
        autoTransferEnabled: true,
        autoTransferAmountMinor: result.amountMinor,
        autoTransferDay: result.day,
      );
      refreshDependentControls(ref, child.id);
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Schedule saved.'),
        ));
    } catch (e) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_describeControlsError(e)),
        ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dependentControlsProvider(child.id));

    return _CardShell(
      child: async.when(
        loading: () => const _CardLoading(label: 'Auto-Release'),
        error: (e, _) => _CardError(
          label: 'Auto-Release',
          message: _describeControlsError(e),
        ),
        data: (controls) {
          final enabled = controls?.autoTransferEnabled ?? false;
          final amount = controls?.autoTransferAmountMinor;
          final day = controls?.autoTransferDay;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                icon: Icons.update,
                title: 'Auto-Release',
                trailing: Switch(
                  value: enabled,
                  activeColor: Colors.white,
                  activeTrackColor: _greenAccent,
                  onChanged: (v) => _toggle(ref, context, v, controls),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SCHEDULED TRANSFER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textGrey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amount != null ? Money.format(amount) : 'PKR 0.00',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: enabled ? AppColors.onSurface : _textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: _textGrey),
                  const SizedBox(width: 6),
                  Text(
                    day != null ? 'Every ${_dayName(day)}' : 'Not scheduled',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: enabled ? 1.0 : 0.4,
                child: InkWell(
                  onTap: enabled
                      ? () => _openEditSheet(context, ref, controls)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: const [
                        Text(
                          'Edit Schedule',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _greenAccent,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            color: _greenAccent, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentSpendingCard extends ConsumerWidget {
  const _RecentSpendingCard({required this.child});
  final Profile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentSpendingProvider(child.id));

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Spending',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                _ErrorBanner(message: _describeControlsError(e)),
            data: (entries) {
              if (entries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No outgoing transactions yet.',
                    style: TextStyle(color: _textGrey, fontSize: 13),
                  ),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _SpendingRow(
                      entry: entries[i],
                      isLast: i == entries.length - 1,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SpendingRow extends ConsumerWidget {
  const _SpendingRow({required this.entry, required this.isLast});
  final LedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Two cases:
    //   * `expense` row → no in-family receiver, render the category icon
    //     + the user-typed description ("PlayStation Network").
    //   * `transfer` row → existing behaviour: initials avatar + "Sent to X".
    final Widget avatar;
    final String title;

    if (entry.isExpense) {
      final category = entry.categoryEnum;
      avatar = CircleAvatar(
        backgroundColor: const Color(0xFFD9EEDF),
        radius: 22,
        child: Icon(category.icon,
            color: const Color(0xFF006B3C), size: 22),
      );
      final desc = entry.description ?? 'Expense';
      title = '$desc \u00B7 ${category.displayName}';
    } else {
      final familyAsync = ref.watch(familyMembersProvider);
      final receiverId = entry.receiverId;
      final receiver = receiverId == null
          ? null
          : familyAsync.asData?.value
              .cast<Profile?>()
              .firstWhere((p) => p?.id == receiverId, orElse: () => null);
      final receiverName = receiver?.fullName ?? 'Family member';
      final colorSeed = receiverId ?? receiverName;
      avatar = CircleAvatar(
        backgroundColor: AvatarUtils.colorFor(colorSeed),
        radius: 22,
        child: Text(
          AvatarUtils.initial(receiverName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
      title = 'Sent to $receiverName';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRelative(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${Money.format(entry.amountMinor)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Edit-schedule bottom sheet ----------

class _EditScheduleResult {
  const _EditScheduleResult({required this.amountMinor, required this.day});
  final BigInt amountMinor;
  final int day;
}

class _EditScheduleSheet extends StatefulWidget {
  const _EditScheduleSheet({
    required this.initialAmountMinor,
    required this.initialDay,
  });

  final BigInt initialAmountMinor;
  final int initialDay;

  @override
  State<_EditScheduleSheet> createState() => _EditScheduleSheetState();
}

class _EditScheduleSheetState extends State<_EditScheduleSheet> {
  late TextEditingController _amountCtrl;
  late int _day;
  String? _error;

  @override
  void initState() {
    super.initState();
    final majorWhole =
        widget.initialAmountMinor ~/ BigInt.from(100);
    final majorFrac = widget.initialAmountMinor % BigInt.from(100);
    final fracStr = majorFrac.toString().padLeft(2, '0');
    _amountCtrl = TextEditingController(text: '$majorWhole.$fracStr');
    _day = widget.initialDay;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final parsed = Money.parseMajorToMinor(_amountCtrl.text);
    if (parsed == null) {
      setState(() => _error = 'Enter a positive amount (e.g. 50 or 50.00).');
      return;
    }
    Navigator.of(context).pop(
      _EditScheduleResult(amountMinor: parsed, day: _day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Edit Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: _textGrey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              prefixText: 'Rs. ',
              filled: true,
              fillColor: _cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Day of the week',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: _textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 7; i++)
                ChoiceChip(
                  label: Text(_dayName(i)),
                  selected: _day == i,
                  onSelected: (_) => setState(() => _day = i),
                  selectedColor: _greenAccentBg,
                  backgroundColor: _cardSurface,
                  labelStyle: TextStyle(
                    color: _day == i ? _greenAccent : AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _greenAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Save schedule',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Shared shells / banners ----------

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title, this.trailing});
  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: _greenAccentBg,
              radius: 18,
              child: Icon(icon, color: _greenAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _CardLoading extends StatelessWidget {
  const _CardLoading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeader(icon: Icons.tune, title: label),
        const SizedBox(height: 24),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.label, required this.message});
  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeader(icon: Icons.tune, title: label),
        const SizedBox(height: 16),
        _ErrorBanner(message: message),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              size: 18, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.saving, required this.justSaved});
  final bool saving;
  final bool justSaved;

  @override
  Widget build(BuildContext context) {
    if (saving) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (justSaved) {
      return Row(
        children: [
          Icon(Icons.check_circle,
              size: 18, color: _greenAccent),
          const SizedBox(width: 4),
          const Text(
            'Saved',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _greenAccent,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// ---------- Helpers ----------

String _dayName(int dow) {
  const names = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  if (dow < 0 || dow > 6) return '—';
  return names[dow];
}

/// Whole-rupee formatter with thousands separators: 10000 -> "10,000".
/// Used for the live slider readout where Money.format would also add a
/// '.00' suffix that doesn't fit the compact display.
String _formatRupeesWhole(int rupees) {
  final s = rupees.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _formatRelative(DateTime ts) {
  final local = ts.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24 && local.day == now.day) {
    final h = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $h:$m $ampm';
  }
  if (diff.inDays < 2) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${local.day}/${local.month}/${local.year}';
}

String _describeControlsError(Object e) {
  final msg = e.toString();
  if (msg.contains('Not authenticated')) return 'Please sign in again.';
  if (msg.contains('Only parents')) {
    return 'Only parents in this family can change these settings.';
  }
  if (msg.contains('Target is not a child') ||
      msg.contains('not a child')) {
    return 'These controls can only be applied to children.';
  }
  if (msg.contains('different family') || msg.contains('Cross-family')) {
    return 'That person is not in your family.';
  }
  if (msg.contains('Auto-transfer requires') ||
      msg.contains('amount and a day')) {
    return 'Auto-transfer needs both an amount and a day of the week.';
  }
  if (msg.contains('day of week') || msg.contains('between 0 and 6')) {
    return 'Pick a valid day of the week.';
  }
  return 'Could not save settings. Please try again.';
}
