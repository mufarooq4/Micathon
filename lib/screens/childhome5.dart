import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/money_request.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/models/transaction.dart';
import 'package:micathon/screens/Monereq13.dart';
import 'package:micathon/screens/Sendmoney12.dart';
import 'package:micathon/screens/child_activity6.dart';
import 'package:micathon/screens/child_view_of_family_tree7.dart';
import 'package:micathon/screens/dependent_approval11.dart';
import 'package:micathon/screens/settings_screen.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/add_expense_fab.dart';
import 'package:micathon/widgets/avatar_utils.dart';

/// Wrapper kept for the router. Delegates to [ChildHomeScreen]; the root
/// [MaterialApp] in `main.dart` provides theme + Navigator.
class ChildHome extends StatelessWidget {
  const ChildHome({super.key});

  @override
  Widget build(BuildContext context) => const ChildHomeScreen();
}

class ChildHomeScreen extends ConsumerWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).asData?.value;
    return Scaffold(
      appBar: _buildAppBar(profile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChildBalanceHero(profile: profile),
            const SizedBox(height: 16),
            const _RequestMoneyPill(),
            const SizedBox(height: 24),
            const _LimitsSection(),
            const SizedBox(height: 32),
            const _IncomingRequestsSection(),
            const SizedBox(height: 32),
            const _MyRequestsSection(),
            const SizedBox(height: 96),
          ],
        ),
      ),
      floatingActionButton: const AddExpenseFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(Profile? profile) {
    final initial = AvatarUtils.initial(profile?.fullName);
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 24.0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[200], height: 1.0),
      ),
      title: const Row(
        children: [
          Icon(Icons.account_balance, color: Colors.indigo),
          SizedBox(width: 8),
          Text(
            'Kafeel',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF006B3C),
            radius: 16,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.95),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 0,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChildActivityScreen()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChildDashboardScreen()),
            );
          } else if (index == 3) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.receipt_long),
            ),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.account_tree),
            ),
            label: 'Tree',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.settings),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ChildBalanceHero extends ConsumerWidget {
  const _ChildBalanceHero({required this.profile});
  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceLabel = profile == null
        ? '...'
        : Money.format(profile!.balanceMinor, currency: 'PKR');
    return Container(
      decoration: BoxDecoration(
        color: _limitsGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _limitsGreen.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: _BalanceHeroPattern()),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    balanceLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _limitsGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _openSendMoney(context, ref),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Send Money',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSendMoney(BuildContext context, WidgetRef ref) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
    );
  }
}

/// Secondary "Request money" pill rendered just below the balance hero on
/// the child home. Replaces the old in-card Request button — this is now a
/// quieter, demoted action so Send Money is unambiguously the primary CTA.
class _RequestMoneyPill extends StatelessWidget {
  const _RequestMoneyPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const RequestMoneyScreen()),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: _limitsGreenBg,
          foregroundColor: _limitsGreen,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        icon: const Icon(Icons.call_received, size: 16),
        label: const Text(
          'Request money',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

/// Translucent geometric flourish anchored to the right edge of the dark-green
/// balance hero. Pure decoration — no interactivity, no dependency on data.
/// Uses only `Colors.white.withOpacity(...)` to stay on-brand without
/// introducing any new color tokens.
class _BalanceHeroPattern extends StatelessWidget {
  const _BalanceHeroPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
              ),
            ),
          ),
          Positioned(
            top: 110,
            right: 40,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.11),
                ),
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: 90,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white.withOpacity(0.09),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pending requests directed at this child by a sibling.
///
/// Mirrors the parent's approval card: the same `myIncomingPendingRequestsProvider`
/// stream is used (it just filters `approver_id == me`), so any request a sibling
/// pointed at this user will surface here with Approve / Decline buttons. The
/// underlying `act_on_request` RPC handles the balance transfer.
class _IncomingRequestsSection extends ConsumerWidget {
  const _IncomingRequestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(myIncomingPendingRequestsProvider);
    final familyAsync = ref.watch(familyMembersProvider);

    return pendingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => _ErrorBanner(message: 'Could not load requests: $e'),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        final family = familyAsync.asData?.value ?? const <Profile>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (requests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8D6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${requests.length} New',
                      style: const TextStyle(
                        color: Color(0xFFB95300),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            for (final req in requests) ...[
              _IncomingRequestCard(
                request: req,
                requester: _findProfile(family, req.requesterId),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  static Profile? _findProfile(List<Profile> list, String id) {
    for (final p in list) {
      if (p.id == id) return p;
    }
    return null;
  }
}

class _IncomingRequestCard extends ConsumerStatefulWidget {
  const _IncomingRequestCard({required this.request, required this.requester});

  final MoneyRequest request;
  final Profile? requester;

  @override
  ConsumerState<_IncomingRequestCard> createState() =>
      _IncomingRequestCardState();
}

class _IncomingRequestCardState extends ConsumerState<_IncomingRequestCard> {
  bool _busy = false;

  Future<void> _act(String action) async {
    setState(() => _busy = true);
    try {
      await ref.read(requestsRepositoryProvider).actOnRequest(
            requestId: widget.request.id,
            action: action,
          );
      refreshRequests(ref);
      if (action == 'approve') {
        // Approval moves money out of this child's balance into the requester's,
        // so both balances need a fresh fetch.
        refreshBalancesAndMembers(ref);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(action == 'approve'
                ? 'Request approved and money sent.'
                : 'Request declined.'),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            content: Text(_describeIncomingError(e)),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.requester?.fullName ?? 'Family member';
    final initial = AvatarUtils.initial(name);
    final color = AvatarUtils.colorFor(widget.requester?.id ?? name);
    final amountLabel = Money.format(widget.request.amountMinor);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 20,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: _limitsTextDark,
                          fontSize: 14,
                          fontFamily: 'Public Sans',
                        ),
                        children: [
                          TextSpan(
                            text: name,
                            style: const TextStyle(
                              color: _limitsGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' wants '),
                          TextSpan(
                            text: amountLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(widget.request.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amountLabel,
                style: const TextStyle(
                  color: _limitsTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _limitsTextDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _busy ? null : () => _act('decline'),
                  child: const Text('Decline',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _limitsGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _busy ? null : () => _act('approve'),
                  child: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Approve',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _describeIncomingError(Object e) {
  final msg = e.toString();
  if (msg.contains('Insufficient balance')) return 'Insufficient balance.';
  if (msg.contains('Not authenticated')) return 'Please sign in again.';
  if (msg.contains('Cannot send')) return 'You cannot transact with yourself.';
  if (msg.contains('approve money requests') ||
      msg.contains('only parents') ||
      msg.contains('not authorized')) {
    return 'Sibling approvals aren\'t enabled on the server yet.';
  }
  // Fall through to surface the actual Postgres / PostgrestException message
  // so we can debug. Trim long stack-trace prefixes to keep the snackbar
  // readable.
  final trimmed = _extractPostgrestMessage(msg);
  return 'Could not act on request: $trimmed';
}

/// Best-effort extraction of the human-readable bit of a
/// PostgrestException.toString() — the format is:
///   `PostgrestException(message: <real message>, code: <sqlstate>, …)`.
/// If we can't find it, fall back to the first 160 chars of the raw text.
String _extractPostgrestMessage(String raw) {
  final m = RegExp(r'message:\s*([^,]+?)(?:,\s*(?:code|details|hint):|$)')
      .firstMatch(raw);
  final extracted = m?.group(1)?.trim();
  if (extracted != null && extracted.isNotEmpty) return extracted;
  return raw.length > 160 ? '${raw.substring(0, 160)}…' : raw;
}

class _MyRequestsSection extends ConsumerWidget {
  const _MyRequestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myOutgoingRequestsProvider);
    final family = ref.watch(familyMembersProvider).asData?.value ??
        const <Profile>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                      builder: (_) => const MyRequestsScreen()),
                );
              },
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        requestsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _ErrorBanner(message: 'Could not load requests: $e'),
          data: (all) {
            final pending = all.where((r) => r.isPending).take(3).toList();
            if (pending.isEmpty) {
              return const _EmptyState(
                icon: Icons.inbox_outlined,
                message:
                    'You have no pending requests. Tap Request Money to send one.',
              );
            }
            return Column(
              children: [
                for (final r in pending) ...[
                  _MyRequestCard(
                    request: r,
                    approver: _findProfile(family, r.approverId),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  static Profile? _findProfile(List<Profile> list, String? id) {
    if (id == null) return null;
    for (final p in list) {
      if (p.id == id) return p;
    }
    return null;
  }
}

class _MyRequestCard extends StatelessWidget {
  const _MyRequestCard({required this.request, required this.approver});

  final MoneyRequest request;
  final Profile? approver;

  @override
  Widget build(BuildContext context) {
    final amount = Money.format(request.amountMinor);
    final approverName = approver?.fullName ?? 'family member';
    final approverIsParent = approver?.role == UserRole.parent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.amber[100],
                radius: 20,
                child: Icon(Icons.access_time_filled,
                    color: Colors.amber[700], size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontFamily: 'Public Sans',
                        ),
                        children: [
                          const TextSpan(text: 'You requested '),
                          TextSpan(
                            text: amount,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' from '),
                          TextSpan(
                            text: approverName,
                            style: const TextStyle(
                              color: Color(0xFF006B3C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(request.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_filled,
                    color: Colors.amber[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  approverIsParent
                      ? 'Pending Parent Approval'
                      : 'Pending Approval',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey[400]),
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
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spending Controls — read-only mirror of the parent's slider + schedule.
//
// The data comes from the same dependent_controls table the parent writes
// to from ViewFamilyMemberChild8.dart. RLS lets any same-family member
// SELECT, so the child reading their own row is safe and supabase realtime
// pushes updates the moment the parent moves the slider.
// ---------------------------------------------------------------------------

const Color _limitsGreen = Color(0xFF006B3C);
const Color _limitsGreenBg = Color(0xFFD9EEDF);
const Color _limitsTextDark = Color(0xFF0F172A);
const Color _limitsTextGrey = Color(0xFF6B7280);

class _LimitsSection extends ConsumerWidget {
  const _LimitsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).asData?.value;
    if (profile == null) return const SizedBox.shrink();
    // Defensive: this screen is wired up only for children, but if it ever
    // gets dropped into a different navigator we don't want a parent
    // viewing their own row of controls here.
    if (profile.role != UserRole.child) return const SizedBox.shrink();

    final controlsAsync = ref.watch(dependentControlsProvider(profile.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending Limits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _limitsTextDark,
          ),
        ),
        const SizedBox(height: 12),
        controlsAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => _ErrorBanner(
            message:
                'Could not load your spending limits. ${_extractPostgrestMessage(e.toString())}',
          ),
          data: (controls) {
            final hasLimit = controls?.monthlyLimitMinor != null;
            final hasSchedule = controls != null &&
                controls.autoTransferEnabled &&
                controls.autoTransferAmountMinor != null &&
                controls.autoTransferDay != null;

            if (!hasLimit && !hasSchedule) {
              return _LimitsCardShell(
                child: Text(
                  "Your parent hasn't set any limits or scheduled transfers yet.",
                  style: TextStyle(
                    fontSize: 14,
                    color: _limitsTextGrey,
                    height: 1.4,
                  ),
                ),
              );
            }

            final limitCard = hasLimit
                ? _LimitsCardShell(
                    child: _LimitTile(
                      amountMinor: controls!.monthlyLimitMinor!,
                      childId: profile.id,
                    ),
                  )
                : null;
            final scheduleCard = hasSchedule
                ? _AutoTransferTile(
                    amountMinor: controls.autoTransferAmountMinor!,
                    day: controls.autoTransferDay!,
                  )
                : null;

            final cards = <Widget>[
              ?limitCard,
              ?scheduleCard,
            ];

            // Single card present → render full width, no spacing needed.
            if (cards.length == 1) return cards.single;

            // Both present → always stacked vertically, full width each.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cards[0],
                const SizedBox(height: 12),
                cards[1],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LimitsCardShell extends StatelessWidget {
  const _LimitsCardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Monthly Limit card with a live, month-to-date progress bar.
///
/// The progress is computed in-widget (mirrors `_wouldExceedMonthlyLimit` in
/// `Sendmoney12.dart` verbatim — same provider, same UTC month boundary). We
/// deliberately do NOT extract a shared helper to keep this redesign's diff
/// minimal and to match the prompt's instruction to "copy that pattern
/// verbatim, do not extract it into a shared helper".
class _LimitTile extends ConsumerWidget {
  const _LimitTile({required this.amountMinor, required this.childId});

  final BigInt amountMinor;
  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paused = amountMinor == BigInt.zero;

    // Month-to-date spend: same shape as Sendmoney12._wouldExceedMonthlyLimit.
    final now = DateTime.now().toUtc();
    final monthStartUtc = DateTime.utc(now.year, now.month, 1);
    final all = ref.watch(familyTransactionsProvider).asData?.value ??
        const <LedgerEntry>[];
    var spent = BigInt.zero;
    for (final t in all) {
      if (t.senderId != childId) continue;
      if (t.createdAt.toUtc().isBefore(monthStartUtc)) continue;
      spent += t.amountMinor;
    }

    final double progress;
    if (paused) {
      progress = 1.0; // Renders as fully grey (we override the colour below).
    } else {
      final ratio = spent / amountMinor;
      progress = ratio.isFinite ? ratio.clamp(0.0, 1.0) : 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Monthly Limit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: _limitsTextGrey,
                        ),
                      ),
                      if (paused) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '(paused)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Money.format(amountMinor),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _limitsTextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 22, color: _limitsTextGrey),
                  SizedBox(width: 6),
                  Icon(Icons.calendar_today,
                      size: 16, color: _limitsTextGrey),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFEEF2EE),
            valueColor: AlwaysStoppedAnimation<Color>(
              paused ? const Color(0xFFCBD5D1) : _limitsGreen,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ${Money.format(spent)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _limitsTextGrey,
              ),
            ),
            Text(
              'Total: ${Money.format(amountMinor)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _limitsTextGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Weekly Allowance card. Renders its own light-green tinted container so it
/// stands apart from the white Monthly Limit card visually — that's why this
/// widget is NOT wrapped in `_LimitsCardShell` over in `_LimitsSection`.
class _AutoTransferTile extends StatelessWidget {
  const _AutoTransferTile({required this.amountMinor, required this.day});
  final BigInt amountMinor;
  final int day;

  @override
  Widget build(BuildContext context) {
    final dayName = _dayName(day);
    final dayInitial = dayName.isNotEmpty ? dayName[0] : '?';
    // Day-of-month a child's weekly allowance will *next* land — purely
    // decorative, so we use today's day-of-month if the day-of-week matches,
    // otherwise compute the next occurrence. Cheap & local: no provider read.
    final today = DateTime.now();
    final daysUntil = (day - today.weekday % 7 + 7) % 7;
    final nextDate = today.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
    final dayOfMonth = nextDate.day;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _limitsGreenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _limitsGreen, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayInitial,
                  style: const TextStyle(
                    color: _limitsGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '$dayOfMonth',
                  style: const TextStyle(
                    color: _limitsGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Allowance',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _limitsGreen,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Money.format(amountMinor),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _limitsTextDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scheduled for $dayName',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _limitsTextGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Postgres `extract(dow from ...)` convention: 0 = Sunday … 6 = Saturday.
/// Kept private so this file remains self-contained — there's a sibling
/// helper in ViewFamilyMemberChild8.dart but we deliberately don't share it.
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
  if (dow < 0 || dow > 6) return 'Unknown';
  return names[dow];
}

String _formatTimestamp(DateTime ts) {
  final local = ts.toLocal();
  final now = DateTime.now();
  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = local.year == yesterday.year &&
      local.month == yesterday.month &&
      local.day == yesterday.day;
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  if (isToday) return 'Today, $hh:$mm';
  if (isYesterday) return 'Yesterday, $hh:$mm';
  return '${local.day}/${local.month}/${local.year}, $hh:$mm';
}
