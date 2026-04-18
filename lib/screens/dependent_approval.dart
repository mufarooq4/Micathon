import 'package:flutter/material.dart';

void main() {
  runApp(const Dependent_approval());
}

class Dependent_approval extends StatelessWidget {
  const Dependent_approval({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neobank App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Manrope', // Make sure to add this font in pubspec.yaml if needed
        scaffoldBackgroundColor: const Color(0xFFFAF9F3),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B3C)),
        useMaterial3: true,
      ),
      home: const IncomingRequestScreen(),
    );
  }
}

class IncomingRequestScreen extends StatelessWidget {
  const IncomingRequestScreen({super.key});

  // Color Palette matches the HTML
  static const Color primaryColor = Color(0xFF006B3C);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color bgColor = Color(0xFFFAF9F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. Top App Bar placed in Scaffold slot prevents top overlap
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCFB),
        surfaceTintColor: Colors.transparent, // Prevents scroll color bleeding
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://ui-avatars.com/api/?name=Kafeel&background=random',
                  ), // Placeholder image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kafeel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: darkGreen,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: darkGreen),
            splashRadius: 24,
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // 2. Main Scrollable Content
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 24),
              _buildInfoCards(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'By approving, you agree to the family terms and account monitoring.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 3. Bottom Nav placed in Scaffold slot prevents bottom overlap
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Decorative blur background element
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    blurRadius: 40,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'K',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Incoming Family Request',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: darkGreen,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kafeel Parent wants to add you as a Child in their family tree.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Monthly Spending Limit',
          value: 'PKR 10,000',
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          icon: Icons.update,
          title: 'Auto-Release Allowance',
          value: 'PKR 2,000 every Saturday',
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          icon: Icons.visibility,
          title: 'Permissions',
          value: 'Parent can view transaction history.',
          isPermissionVariant: true,
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    bool isPermissionVariant = false,
  }) {
    final bgColor = isPermissionVariant ? darkGreen.withOpacity(0.05) : Colors.white;
    final borderColor = isPermissionVariant ? darkGreen.withOpacity(0.1) : Colors.grey.shade100;
    final iconBgColor = isPermissionVariant ? darkGreen : Colors.green.shade50;
    final iconColor = isPermissionVariant ? Colors.white : primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isPermissionVariant
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isPermissionVariant ? Colors.grey.shade600 : Colors.grey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isPermissionVariant ? 14 : 18,
                    fontWeight: isPermissionVariant ? FontWeight.w600 : FontWeight.w800,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: primaryColor.withOpacity(0.4),
          ),
          child: const Text(
            'Approve & Link',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Decline Request',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -4),
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), // Added bottom padding for safe area
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_filled, label: 'Home', isActive: true),
          _buildNavItem(icon: Icons.history, label: 'Activity'),
          _buildNavItem(icon: Icons.account_tree_outlined, label: 'Tree'),
          _buildNavItem(icon: Icons.settings_outlined, label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false}) {
    final color = isActive ? primaryColor : Colors.grey.shade400;
    
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}