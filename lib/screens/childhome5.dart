import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/money_request.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/screens/Monereq13.dart';
import 'package:micathon/screens/child_activity6.dart';
import 'package:micathon/screens/child_view_of_family_tree7.dart';
import 'package:micathon/screens/dependent_approval11.dart';
import 'package:micathon/screens/settings_screen.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
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
            const SizedBox(height: 32),
            const _MyRequestsSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
        color: const Color(0xFF006B3C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006B3C).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -64,
              right: -64,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balanceLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF006B3C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () =>
                              _openRequestMoney(context, ref),
                          icon: const Icon(Icons.call_received),
                          label: const Text(
                            'Request Money',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () =>
                              _openRequestMoney(context, ref),
                          icon: const Icon(Icons.add, color: Colors.white),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRequestMoney(BuildContext context, WidgetRef ref) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const RequestMoneyScreen()),
    );
  }
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
    final approverName = approver?.fullName ?? 'Parent';
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
                  'Pending Parent Approval',
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
