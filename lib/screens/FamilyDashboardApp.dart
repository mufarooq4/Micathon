import 'package:flutter/material.dart';

// --- Theme Colors Based on Tailwind Config ---
class AppColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color primary = Color(0xFF00502C);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceContainer = Color(0xFFEFEEEB);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);
  static const Color secondary = Color(0xFF46654F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF974147);
  static const Color onTertiaryContainer = Color(0xFFFFC8C9);
  static const Color primaryFixedDim = Color(0xFF81D99F);
}

class FamilyDashboardApp extends StatelessWidget {
  const FamilyDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tree Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Manrope', // Ensure this is loaded via google_fonts or pubspec
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For the floating bottom nav
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: AppBar(
            backgroundColor: AppColors.background.withOpacity(0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'K',
                        style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kafeel',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black54),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
        child: Column(
          children: [
            // Total Balance Hero
            Container(
              width: double.infinity,
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
              child: const Column(
                children: [
                  Text(
                    'TOTAL FAMILY BALANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rs. 4,250.00',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Dependants List
            Stack(
              alignment: Alignment.center,
              children: [
                // Growth Indicator Line (Abstract Tree Trunk) - Visible on wider screens usually, mocked here
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _buildDependantCard(
                      name: 'Sarah',
                      status: 'On Budget',
                      amount: 'Rs. 150.00',
                      avatarInitial: 'S',
                      avatarColor: AppColors.secondary,
                      onAvatarColor: AppColors.onSecondary,
                      ringColor: AppColors.primaryFixedDim,
                    ),
                    const SizedBox(height: 24),
                    // Leo - Offset to right slightly as per HTML "ml-auto w-[90%]"
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: _buildDependantCard(
                          name: 'Leo', // Fixed typo from HTML where name was 'Rs. 24.50'
                          status: 'Near Limit',
                          amount: 'Rs. 24.50',
                          avatarInitial: 'L',
                          avatarColor: AppColors.error,
                          onAvatarColor: AppColors.onError,
                          ringColor: AppColors.error.withOpacity(0.4),
                          statusColor: AppColors.error,
                          amountColor: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDependantCard(
                      name: 'Maya',
                      status: 'On Budget',
                      amount: 'Rs. 320.00',
                      avatarInitial: 'M',
                      avatarColor: AppColors.tertiaryContainer,
                      onAvatarColor: AppColors.onTertiaryContainer,
                      ringColor: AppColors.primaryFixedDim,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Add Dependant Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: AppColors.onPrimary),
              label: const Text(
                'Add Dependant',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _CustomBottomNavBar(),
    );
  }

  Widget _buildDependantCard({
    required String name,
    required String status,
    required String amount,
    required String avatarInitial,
    required Color avatarColor,
    required Color onAvatarColor,
    required Color ringColor,
    Color statusColor = AppColors.onSurfaceVariant,
    Color amountColor = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.02),
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
              border: Border.all(color: ringColor, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: avatarColor,
              child: Text(
                avatarInitial,
                style: TextStyle(
                  color: onAvatarColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const Text(
                'Available',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(icon: Icons.home_outlined, label: 'Home', isActive: false),
          _NavBarItem(icon: Icons.history, label: 'Activity', isActive: false),
          _NavBarItem(icon: Icons.account_tree, label: 'Tree', isActive: true),
          _NavBarItem(icon: Icons.settings_outlined, label: 'Settings', isActive: false),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.onSurface.withOpacity(0.4);
    final bgColor = isActive ? AppColors.surfaceContainerHighest.withOpacity(0.5) : Colors.transparent;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}