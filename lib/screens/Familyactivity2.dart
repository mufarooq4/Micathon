import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/screens/parent_home1.dart';
import 'package:micathon/screens/parent_view_family_tree3.dart';
import 'package:micathon/screens/settings_screen.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/ledger_list.dart';

class Familyactivity extends StatelessWidget {
  const Familyactivity({super.key});

  @override
  Widget build(BuildContext context) => const RecentActivityScreen();
}

class RecentActivityScreen extends ConsumerStatefulWidget {
  const RecentActivityScreen({super.key});

  static const Color primary = Color(0xFF00502C);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color surfaceLow = Color(0xFFF4F3F1);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);

  @override
  ConsumerState<RecentActivityScreen> createState() =>
      _RecentActivityScreenState();
}

class _RecentActivityScreenState extends ConsumerState<RecentActivityScreen> {
  String? _filterUserId;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myProfileProvider).asData?.value;
    final familyAsync = ref.watch(familyMembersProvider);
    final txAsync = ref.watch(familyTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6).withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: RecentActivityScreen.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Color(0xFF90E9AD),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kafeel',
              style: TextStyle(
                color: RecentActivityScreen.primary,
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
                'Recent Activity',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: RecentActivityScreen.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unified transaction feed for the whole family.',
                style: TextStyle(
                  color: RecentActivityScreen.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              familyAsync.when(
                data: (family) => _buildFilterRow(family, me?.id),
                loading: () => const SizedBox(height: 32),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              txAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorBanner(message: 'Could not load: $e'),
                data: (entries) {
                  final filtered = _filterUserId == null
                      ? entries
                      : entries
                          .where((e) =>
                              e.senderId == _filterUserId ||
                              e.receiverId == _filterUserId)
                          .toList();
                  final family =
                      familyAsync.asData?.value ?? const <Profile>[];
                  return LedgerList(
                    entries: filtered,
                    familyMembers: family,
                    currentUserId: me?.id ?? '',
                    emptyMessage:
                        'No transactions yet. Send some money to get the ledger started.',
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

  Widget _buildFilterRow(List<Profile> family, String? meId) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterTab('All', null),
          for (final p in family)
            _filterTab(p.id == meId ? 'Me' : p.fullName, p.id),
        ],
      ),
    );
  }

  Widget _filterTab(String label, String? userId) {
    final active = _filterUserId == userId;
    return GestureDetector(
      onTap: () => setState(() => _filterUserId = userId),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color:
              active ? RecentActivityScreen.primary : const Color(0xFFE3E2E0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : RecentActivityScreen.onSurface,
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
            color: RecentActivityScreen.primary.withOpacity(0.06),
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
              _navItem(Icons.home_outlined, 'HOME', onTap: () {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ParentHome()),
                );
              }),
              _navItem(Icons.history, 'ACTIVITY', isActive: true),
              _navItem(Icons.account_tree_outlined, 'TREE', onTap: () {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const ParentViewFamilyTree()),
                );
              }),
              _navItem(Icons.settings_outlined, 'SETTINGS', onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
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
                  ? RecentActivityScreen.primary
                  : RecentActivityScreen.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isActive
                    ? RecentActivityScreen.primary
                    : RecentActivityScreen.onSurface.withOpacity(0.4),
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
