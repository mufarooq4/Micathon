import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Column(
      key: const ValueKey('transactions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History with ${widget.member.fullName}',
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
              return (t.senderId == mine && t.receiverId == widget.member.id) ||
                  (t.senderId == widget.member.id && t.receiverId == mine);
            }).toList();
            if (filtered.isEmpty) {
              return _emptyTab('No transactions with ${widget.member.fullName} yet.');
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
                    _txRow(filtered[i], mine),
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

  Widget _txRow(LedgerEntry e, String meId) {
    final outgoing = e.isOutgoingFor(meId);
    final amount = outgoing
        ? '-${Money.format(e.amountMinor)}'
        : '+${Money.format(e.amountMinor)}';
    final title = outgoing
        ? 'Sent to ${widget.member.fullName}'
        : 'Received from ${widget.member.fullName}';
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
              return (r.requesterId == mine &&
                      r.approverId == widget.member.id) ||
                  (r.requesterId == widget.member.id && r.approverId == mine);
            }).toList();
            if (filtered.isEmpty) {
              return _emptyTab('No requests with ${widget.member.fullName} yet.');
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
                    _requestRow(filtered[i], mine),
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

  Widget _requestRow(MoneyRequest r, String meId) {
    final outgoing = r.requesterId == meId;
    final color = _statusColor(r.status);
    final amount = Money.format(r.amountMinor);
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
                outgoing
                    ? 'You requested $amount'
                    : '${widget.member.fullName} requested $amount',
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
