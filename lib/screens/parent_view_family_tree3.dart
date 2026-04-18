import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/screens/Familyactivity2.dart';
import 'package:micathon/screens/ViewFamilyMemberChild8.dart';
import 'package:micathon/screens/invite_dependent_screen.dart';
import 'package:micathon/screens/parent_home1.dart';
import 'package:micathon/screens/settings_screen.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/avatar_utils.dart';

class ParentViewFamilyTree extends StatelessWidget {
  const ParentViewFamilyTree({super.key});

  @override
  Widget build(BuildContext context) => const DashboardScreen();
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myProfileProvider).asData?.value;
    final familyAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6).withOpacity(0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00502C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kafeel',
              style: TextStyle(
                color: Color(0xFF00502C),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0x991A1C1A)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: familyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load family: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
          ),
        ),
        data: (members) {
          final dependents = members.where((p) => p.id != me?.id).toList();
          final totalMinor = members.fold<BigInt>(
            BigInt.zero,
            (a, p) => a + p.balanceMinor,
          );
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TotalBalanceCard(totalMinor: totalMinor),
                  const SizedBox(height: 48),
                  if (dependents.isEmpty)
                    _emptyDependents()
                  else
                    Column(
                      children: [
                        for (var i = 0; i < dependents.length; i++) ...[
                          if (i % 2 == 1)
                            Align(
                              alignment: Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: 0.9,
                                child: _DependantCard(
                                    member: dependents[i],
                                    onTap: () => _openMember(
                                        context, dependents[i])),
                              ),
                            )
                          else
                            _DependantCard(
                              member: dependents[i],
                              onTap: () =>
                                  _openMember(context, dependents[i]),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => const InviteDependentScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Dependant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00502C),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 10,
                        shadowColor:
                            const Color(0xFF00502C).withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _emptyDependents() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00502C).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.group_add_outlined,
              size: 36, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No dependants yet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1A)),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Add Dependant" to generate an invite code for a child or co-parent.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _openMember(BuildContext context, Profile member) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => FamilyMemberProfileScreen(member: member),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00502C).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.history_rounded, 'Activity'),
              _navItem(2, Icons.account_tree_rounded, 'Tree'),
              _navItem(3, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        final navigator = Navigator.of(context, rootNavigator: true);
        if (index == 0) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const ParentHome()),
          );
        } else if (index == 1) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const Familyactivity()),
          );
        } else if (index == 3) {
          navigator.push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE3E2E0).withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00502C)
                  : const Color(0xFF1A1C1A).withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isSelected
                    ? const Color(0xFF00502C)
                    : const Color(0xFF1A1C1A).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.totalMinor});
  final BigInt totalMinor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00502C).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL FAMILY BALANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: const Color(0xFF3F4941).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Money.format(totalMinor, currency: 'PKR'),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00502C),
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DependantCard extends StatelessWidget {
  const _DependantCard({required this.member, required this.onTap});
  final Profile member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AvatarUtils.colorFor(member.id);
    final initial = AvatarUtils.initial(member.fullName);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00502C).withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF81D99F), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _roleLabel(member.role),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F4941),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Money.format(member.balanceMinor),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00502C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3F4941),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        return '';
    }
  }
}
