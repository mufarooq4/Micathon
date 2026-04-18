import 'package:flutter/material.dart';
import 'package:micathon/screens/Familyactivity2.dart';
import 'package:micathon/screens/manage_dependent4.dart';
import 'package:micathon/screens/parent_home1.dart';

void main() {
  runApp(const ParentViewFamilyTree());
}

class ParentViewFamilyTree extends StatelessWidget {
  const ParentViewFamilyTree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tree Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Manrope', // Make sure to add this to your pubspec.yaml
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        primaryColor: const Color(0xFF00502C),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2; // Default to 'Tree' tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ---
      // Using standard AppBar automatically prevents body content from hiding underneath it.
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
                color: Color(0xFFE3E2E0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00502C), // Primary
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
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0x991A1C1A)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Total Balance Hero Card
              Container(
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
                    const Text(
                      'Rs. 4,250.00',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00502C),
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 2. Family Tree List
              Stack(
                alignment: Alignment.center,
                children: [
                  // Vertical Tree Line (Hidden on very small screens in HTML, visible here)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF00502C).withOpacity(0.2),
                            const Color(0xFF00502C).withOpacity(0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  
                  Column(
                    children: [
                      // Sarah
                      _buildDependantCard(
                        name: 'Sarah',
                        status: 'On Budget',
                        amount: 'Rs. 150.00',
                        initial: 'S',
                        avatarColor: const Color(0xFF46654F),
                        isWarning: false,
                        onTap: () => _openManageDependent(context),
                      ),
                      const SizedBox(height: 24),
                      
                      // Leo (Indented / Offset design from the HTML)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child: _buildDependantCard(
                            name: 'Leo', // Fixed typo from HTML
                            status: 'Near Limit',
                            amount: 'Rs. 24.50',
                            initial: 'L',
                            avatarColor: const Color(0xFFBA1A1A), // Error Red
                            isWarning: true,
                            onTap: () => _openManageDependent(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Maya
                      _buildDependantCard(
                        name: 'Maya',
                        status: 'On Budget',
                        amount: 'Rs. 320.00',
                        initial: 'M',
                        avatarColor: const Color(0xFF974147),
                        isWarning: false,
                        onTap: () => _openManageDependent(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 3. Primary CTA
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
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
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFF00502C).withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Extra padding at the bottom of the scroll view
            ],
          ),
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      // Placing it here prevents layout overlap 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00502C).withOpacity(0.06),
              blurRadius: 40,
              offset: const Offset(0, -20),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.history_rounded, 'Activity'),
                _buildNavItem(2, Icons.account_tree_rounded, 'Tree'),
                _buildNavItem(3, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openManageDependent(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const Manage_dependent()),
    );
  }

  // Helper widget for dependent cards
  Widget _buildDependantCard({
    required String name,
    required String status,
    required String amount,
    required String initial,
    required Color avatarColor,
    required bool isWarning,
    VoidCallback? onTap,
  }) {
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
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isWarning ? const Color(0xFFBA1A1A).withOpacity(0.4) : const Color(0xFF81D99F),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: avatarColor,
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
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isWarning ? const Color(0xFFBA1A1A) : const Color(0xFF3F4941),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? const Color(0xFF1A1C1A) : const Color(0xFF00502C),
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

  // Helper widget for Bottom Nav Items
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        final navigator = Navigator.of(context, rootNavigator: true);
        if (index == 0) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const ParentHome()),
          );
        } else if (index == 1) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const Familyactivity()),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3E2E0).withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00502C) : const Color(0xFF1A1C1A).withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isSelected ? const Color(0xFF00502C) : const Color(0xFF1A1C1A).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}