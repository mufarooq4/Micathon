import 'package:flutter/material.dart';

// void main() {
//   runApp(const ViewFamilyMemberChild());
// }

// Defining the color palette based on the Tailwind config
class AppColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color primary = Color(0xFF00502C);
  static const Color primaryFixed = Color(0xFF9DF6B9);
  static const Color onPrimaryFixed = Color(0xFF00210F);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F1);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC4E9CC);
  static const Color onSecondaryContainer = Color(0xFF4A6A53);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);
}

class ViewFamilyMemberChild extends StatelessWidget {
  const ViewFamilyMemberChild({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Member Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const FamilyMemberProfileScreen(),
    );
  }
}

class FamilyMemberProfileScreen extends StatefulWidget {
  const FamilyMemberProfileScreen({super.key});

  @override
  State<FamilyMemberProfileScreen> createState() => _FamilyMemberProfileScreenState();
}

class _FamilyMemberProfileScreenState extends State<FamilyMemberProfileScreen> {
  // 0 = Transactions, 1 = Loan Requests
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              
              // Custom Tab Bar
              _buildCustomTabBar(),
              const SizedBox(height: 24),
              
              // Dynamic Content based on selected tab
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTabIndex == 0
                    ? _buildTransactionsTab()
                    : _buildLoansTab(),
              ),
              const SizedBox(height: 24), // Extra bottom padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        onPressed: () {},
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'CH', // Child's own profile initials
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Kafeel',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildProfileHeader() {
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
              color: const Color(0xFF46654F),
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
            child: const Text(
              'D', // Initial for 'Dad'
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Dad',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'PARENT',
              style: TextStyle(
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
                  onPressed: () {},
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
                  label: const Text('Send', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_received, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHighest,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text('Request', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NEW CUSTOM TAB BAR ---
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
          Expanded(child: _buildTabButton('Loan Requests', 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- TRANSACTIONS TAB CONTENT ---
  Widget _buildTransactionsTab() {
    return Column(
      key: const ValueKey('transactions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'History with Dad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildTransactionItem(
                icon: Icons.payments,
                title: 'Monthly Allowance',
                date: 'May 1, 2024',
                amount: '+Rs. 5,000.00',
                isPositive: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceContainerLow, height: 1),
              ),
              _buildTransactionItem(
                icon: Icons.fastfood,
                title: 'Lunch Request Approved',
                date: 'Apr 28, 2024',
                amount: '+Rs. 500.00',
                isPositive: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceContainerLow, height: 1),
              ),
              _buildTransactionItem(
                icon: Icons.send,
                title: 'Sent Money to Dad',
                date: 'Apr 15, 2024',
                amount: '-Rs. 250.00',
                isPositive: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- LOAN REQUESTS TAB CONTENT ---
  Widget _buildLoansTab() {
    return Column(
      key: const ValueKey('loans'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loan Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildLoanItem(
                title: 'School Trip',
                date: 'Requested Today',
                amount: 'Rs. 1,500.00',
                status: 'Pending',
                statusColor: Colors.amber[700]!,
                statusBg: Colors.amber[50]!,
                isOutgoing: true, // Child requested from Dad
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceContainerLow, height: 1),
              ),
              _buildLoanItem(
                title: 'New Sneakers',
                date: 'Requested Apr 10',
                amount: 'Rs. 3,000.00',
                status: 'Approved',
                statusColor: AppColors.primary,
                statusBg: AppColors.secondaryContainer.withOpacity(0.5),
                isOutgoing: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceContainerLow, height: 1),
              ),
              _buildLoanItem(
                title: 'Dad borrowed for coffee',
                date: 'Mar 25, 2024',
                amount: 'Rs. 400.00',
                status: 'Paid Back',
                statusColor: AppColors.onSurfaceVariant,
                statusBg: AppColors.surfaceContainerHighest,
                isOutgoing: false, // Dad requested from Child
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS FOR LIST ITEMS ---
  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required bool isPositive,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPositive ? AppColors.secondaryContainer.withOpacity(0.5) : AppColors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isPositive ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isPositive ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLoanItem({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required bool isOutgoing,
  }) {
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
            isOutgoing ? Icons.arrow_outward : Icons.arrow_downward,
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
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false),
              _buildNavItem(Icons.history, 'Activity', false),
              _buildNavItem(Icons.account_tree, 'Tree', true),
              _buildNavItem(Icons.settings_outlined, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isActive
          ? BoxDecoration(
              color: AppColors.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: isActive ? AppColors.primary : AppColors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}