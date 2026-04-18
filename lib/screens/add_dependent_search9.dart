import 'package:flutter/material.dart';
import 'package:micathon/screens/add_dependent_configuration10.dart';

void main() {
  runApp(const Add_dependent_search());
}

class Add_dependent_search extends StatelessWidget {
  const Add_dependent_search({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafeel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Public Sans', // Or use default sans-serif
        scaffoldBackgroundColor: const Color(0xFFFAF9F3), // stone-50
        useMaterial3: true,
      ),
      home: const AddDependantScreen(),
    );
  }
}

class AddDependantScreen extends StatelessWidget {
  const AddDependantScreen({super.key});

  // Color Palette mapping from Tailwind configuration
  static const Color forest900 = Color(0xFF006B3C);
  static const Color stone50 = Color(0xFFFAF9F3);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone900 = Color(0xFF1C1917);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Top AppBar
      appBar: AppBar(
        backgroundColor: stone50,
        surfaceTintColor: Colors.transparent, // Prevents tinting on scroll
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: stone200, height: 1.0), // border-b
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: forest900),
          onPressed: () {},
        ),
        title: const Text(
          'Kafeel',
          style: TextStyle(
            color: forest900,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: forest900,
              radius: 18,
              child: const Text(
                'JD',
                style: TextStyle(
                  color: stone50,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),

      // 2. Main Scrollable Body
      // Safe from overlap because Scaffold sizes this space appropriately
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            const Text(
              'Add Dependant',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: forest900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your family member's unique account number to link their profile to your Kafeel wallet.",
              style: TextStyle(
                color: stone500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // Search Card
            Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: stone100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                    child: Text(
                      'KAFEEL ACCOUNT NUMBER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: stone400,
                      ),
                    ),
                  ),
                  TextField(
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'KFL - 0000 - 0000',
                      hintStyle: const TextStyle(color: stone400),
                      prefixIcon: const Icon(Icons.fingerprint, color: stone400),
                      filled: true,
                      fillColor: stone100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: forest900, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const Add_dependent_configuration(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forest900,
                      foregroundColor: stone50,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: forest900.withOpacity(0.4),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Search Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info / Explanation Card
            Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: forest900,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: stone50,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy & Approval',
                          style: TextStyle(
                            color: stone50,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'For security, the dependant must manually approve your request from their own app before you can view their balance or top up their vault.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent Searches
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
              child: Text(
                'RECENT SEARCHES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: stone400,
                ),
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildRecentSearch('AH', 'Ali Hamza'),
                _buildRecentSearch('ZK', 'Zainab Khan'),
              ],
            ),
          ],
        ),
      ),

      // 3. Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: stone200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: stone50,
          type: BottomNavigationBarType.fixed,
          currentIndex: 2, // Tree is selected
          selectedItemColor: forest900,
          unselectedItemColor: stone400,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_outlined),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.history),
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
                child: Icon(Icons.settings_outlined),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the recent search bubbles
  Widget _buildRecentSearch(String initials, String name) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: stone200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFD6D3D1), // stone-300
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: stone700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: stone700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}