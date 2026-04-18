import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/screens/childhome5.dart';
import 'package:micathon/screens/child_view_of_family_tree7.dart';
import 'package:micathon/screens/settings_screen.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/ledger_list.dart';

class ChildActivity extends StatelessWidget {
  const ChildActivity({super.key});

  @override
  Widget build(BuildContext context) => const ChildActivityScreen();
}

class ChildActivityScreen extends ConsumerStatefulWidget {
  const ChildActivityScreen({super.key});

  static const Color primary = Color(0xFF00502C);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color surfaceLow = Color(0xFFF4F3F1);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);

  @override
  ConsumerState<ChildActivityScreen> createState() =>
      _ChildActivityScreenState();
}

class _ChildActivityScreenState extends ConsumerState<ChildActivityScreen> {
  // 0 = all, 1 = money in, 2 = money out
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myProfileProvider).asData?.value;
    final familyAsync = ref.watch(familyMembersProvider);
    final txAsync = ref.watch(myTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6).withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: ChildActivityScreen.primary),
          tooltip: 'Back to Home',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
            );
          },
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ChildActivityScreen.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'CH',
                  style: TextStyle(
                    color: Color(0xFF90E9AD),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kafeel',
              style: TextStyle(
                color: ChildActivityScreen.primary,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Activity',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: ChildActivityScreen.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal transaction history.',
                style: TextStyle(
                  color: ChildActivityScreen.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _filterTab('All', 0),
                    _filterTab('Money In', 1),
                    _filterTab('Money Out', 2),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              txAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    _ErrorBanner(message: 'Could not load: $e'),
                data: (entries) {
                  final meId = me?.id ?? '';
                  final filtered = entries.where((e) {
                    if (_filterIndex == 0) return true;
                    final outgoing = e.isOutgoingFor(meId);
                    return _filterIndex == 1 ? !outgoing : outgoing;
                  }).toList();
                  final family =
                      familyAsync.asData?.value ?? const <Profile>[];
                  return LedgerList(
                    entries: filtered,
                    familyMembers: family,
                    currentUserId: meId,
                    emptyMessage:
                        'No transactions yet. Try requesting some money from a parent.',
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _filterTab(String label, int index) {
    final active = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color:
              active ? ChildActivityScreen.primary : const Color(0xFFE3E2E0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : ChildActivityScreen.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6).withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: ChildActivityScreen.primary.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'HOME', tabIndex: 0),
              _navItem(Icons.history, 'ACTIVITY',
                  tabIndex: 1, isActive: true),
              _navItem(Icons.account_tree_outlined, 'TREE', tabIndex: 2),
              _navItem(Icons.settings_outlined, 'SETTINGS', tabIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {required int tabIndex, bool isActive = false}) {
    return InkWell(
      onTap: () {
        if (isActive) return;
        if (tabIndex == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
          );
        } else if (tabIndex == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChildDashboardScreen()),
          );
        } else if (tabIndex == 3) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFE3E2E0).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? ChildActivityScreen.primary
                  : ChildActivityScreen.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isActive
                    ? ChildActivityScreen.primary
                    : ChildActivityScreen.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
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
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}
