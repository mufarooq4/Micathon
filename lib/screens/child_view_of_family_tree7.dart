import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micathon/models/money.dart';
import 'package:micathon/models/profile.dart';
import 'package:micathon/screens/ViewFamilyMemberChild8.dart';
import 'package:micathon/screens/childhome5.dart';
import 'package:micathon/screens/child_activity6.dart';
import 'package:micathon/screens/settings_screen.dart';
import 'package:micathon/state/family_providers.dart';
import 'package:micathon/state/profile_providers.dart';
import 'package:micathon/widgets/avatar_utils.dart';

class ChildViewFamilyTree extends StatelessWidget {
  const ChildViewFamilyTree({super.key});

  @override
  Widget build(BuildContext context) => const ChildDashboardScreen();
}

class ChildDashboardScreen extends ConsumerStatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  ConsumerState<ChildDashboardScreen> createState() =>
      _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends ConsumerState<ChildDashboardScreen> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00502C)),
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
                color: Color(0xFF00502C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  AvatarUtils.initial(me?.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My Family Tree',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00502C),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View your family members and balances.',
                style: TextStyle(
                  color: Color(0xFF3F4941),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              familyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Text('Could not load: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (family) {
                  if (family.isEmpty) {
                    return _emptyFamily();
                  }
                  // Sort: parents first, then me, then siblings.
                  final sorted = [...family]..sort((a, b) {
                      int rank(Profile p) {
                        if (p.role == UserRole.parent) return 0;
                        if (p.id == me?.id) return 1;
                        return 2;
                      }
                      return rank(a).compareTo(rank(b));
                    });
                  return Column(
                    children: [
                      for (var i = 0; i < sorted.length; i++) ...[
                        _MemberCard(
                          member: sorted[i],
                          isMe: sorted[i].id == me?.id,
                          onTap: sorted[i].id == me?.id
                              ? null
                              : () => _openMember(context, sorted[i]),
                        ),
                        if (i < sorted.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _emptyFamily() {
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
          Icon(Icons.family_restroom, size: 36, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No family members yet.',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _openMember(BuildContext context, Profile member) {
    Navigator.of(context).push(
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
        if (isSelected) return;
        setState(() => _selectedIndex = index);
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
          );
        } else if (index == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChildActivityScreen()),
          );
        } else if (index == 3) {
          Navigator.of(context, rootNavigator: true).push(
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

class _MemberCard extends StatelessWidget {
  const _MemberCard(
      {required this.member, required this.isMe, required this.onTap});
  final Profile member;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = AvatarUtils.colorFor(member.id);
    final initial = AvatarUtils.initial(member.fullName);
    final roleLabel = isMe
        ? 'Me'
        : (member.role == UserRole.parent ? 'Parent' : 'Sibling');

    return Material(
      color: Colors.white,
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
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE3E2E0).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3F4941),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Money.format(member.balanceMinor),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00502C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
