import 'package:flutter/material.dart';
import 'package:micathon/screens/childhome5.dart';
import 'package:micathon/screens/child_view_of_family_tree7.dart';
import 'package:micathon/screens/settings_screen.dart';

// void main() {
//   runApp(const ChildActivity());
// }

class ChildActivity extends StatelessWidget {
  const ChildActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafeel Activity - Child',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        fontFamily: 'Manrope', // Add google_fonts package if you want the exact font
        useMaterial3: true,
      ),
      home: const ChildActivityScreen(),
    );
  }
}

class ChildActivityScreen extends StatelessWidget {
  const ChildActivityScreen({super.key});

  // Color Palette Definitions based on your Tailwind Config
  static const Color primary = Color(0xFF00502C);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color surfaceLow = Color(0xFFF4F3F1);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. APP BAR: Handled by Scaffold to prevent overlap
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6).withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primary),
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
                color: primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'CH', // Changed to represent Child Profile
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
                color: primary,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: primary,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                hoverColor: surfaceLow,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // 2. BODY: SafeArea prevents overlapping with notches/status bars
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              const Text(
                'My Activity',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal transaction history and allowances.',
                style: TextStyle(
                  color: onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Filter Tabs - Adjusted for individual use
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterTab('All', isActive: true),
                    _buildFilterTab('Money In'),
                    _buildFilterTab('Money Out'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Activity List - Today
              _buildDateHeader('TODAY'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildTransactionItem(
                      icon: Icons.restaurant_outlined,
                      title: 'Sweetgreen',
                      category: 'Dining',
                      tagLabel: 'SPENT',
                      tagBg: const Color(0xFFE8DEF8),
                      tagColor: const Color(0xFF1D192B),
                      amount: 'PKR -18.20',
                    ),
                    _buildTransactionItem(
                      icon: Icons.payments_outlined,
                      title: 'Allowance Received',
                      category: 'Transfer',
                      tagLabel: 'FROM PARENT',
                      tagBg: const Color(0xFFC4E9CC),
                      tagColor: const Color(0xFF00502C),
                      amount: 'PKR +50.00',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Activity List - Yesterday
              _buildDateHeader('YESTERDAY'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildTransactionItem(
                      icon: Icons.sports_esports_outlined,
                      title: 'PlayStation Network',
                      category: 'Entertainment',
                      tagLabel: 'SPENT',
                      tagBg: const Color(0xFFE8DEF8),
                      tagColor: const Color(0xFF1D192B),
                      amount: 'PKR -9.99',
                    ),
                    _buildTransactionItem(
                      icon: Icons.directions_bus_outlined,
                      title: 'City Transit',
                      category: 'Transport',
                      tagLabel: 'SPENT',
                      tagBg: const Color(0xFFE8DEF8),
                      tagColor: const Color(0xFF1D192B),
                      amount: 'PKR -2.50',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 3. BOTTOM NAV: Also managed by Scaffold
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6).withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.06),
              blurRadius: 40,
              offset: const Offset(0, -20),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_outlined, 'HOME', tabIndex: 0),
                _buildNavItem(context, Icons.history, 'ACTIVITY', tabIndex: 1, isActive: true),
                _buildNavItem(context, Icons.account_tree_outlined, 'TREE', tabIndex: 2),
                _buildNavItem(context, Icons.settings_outlined, 'SETTINGS', tabIndex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget Builders ---

  Widget _buildFilterTab(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? primary : const Color(0xFFE3E2E0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String category,
    required String tagLabel,
    required Color tagBg,
    required Color tagColor,
    required String amount,
    bool isPositive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isPositive)
              Container(
                width: 4,
                color: primary,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFF006B3C) // Primary Container
                            : const Color(0xFFC4E9CC), // Secondary Container
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isPositive
                            ? const Color(0xFF9DF6B9) // Primary fixed
                            : const Color(0xFF006B3C), // Primary container
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: onSurfaceVariant,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFBEC9BE),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tagBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tagLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: tagColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isPositive ? primary : onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    required int tabIndex,
    bool isActive = false,
  }) {
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
              color: isActive ? primary : onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isActive ? primary : onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}