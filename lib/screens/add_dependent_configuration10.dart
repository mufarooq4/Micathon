import 'package:flutter/material.dart';

// void main() {
//   runApp(const Add_dependent_configuration());
// }

class Add_dependent_configuration extends StatelessWidget {
  const Add_dependent_configuration({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafeel - Configure Dependant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PublicSans', // Assuming you add this to pubspec.yaml
        scaffoldBackgroundColor: const Color(0xFFFAF9F3), // stone-50
        useMaterial3: true,
      ),
      home: const ConfigureDependantScreen(),
    );
  }
}

class ConfigureDependantScreen extends StatelessWidget {
  const ConfigureDependantScreen({super.key});

  // Color Palette derived from your Tailwind config
  static const Color emerald900 = Color(0xFF006B3C);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color stone800 = Color(0xFF2D2A22);
  static const Color stone500 = Color(0xFF96875E);
  static const Color stone400 = Color(0xFFBDB08B);
  static const Color stone100 = Color(0xFFF5F3E9);
  static const Color stone50 = Color(0xFFFAF9F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar natively prevents content from sliding underneath it
      appBar: AppBar(
        backgroundColor: stone50,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: emerald900),
          tooltip: 'Back',
          onPressed: () {
            final rootNav = Navigator.of(context, rootNavigator: true);
            if (rootNav.canPop()) {
              rootNav.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: const Text(
          'Kafeel',
          style: TextStyle(
            color: emerald900,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: 'PlayfairDisplay', // Use serif font if available
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: emerald900,
              child: const Text(
                'JD',
                style: TextStyle(
                  color: stone50,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 40),
              _buildRoleSelection(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildBudgetCard(
                      title: 'Monthly Limit',
                      icon: Icons.account_balance_wallet_outlined,
                      amount: '10,000',
                      description: 'Maximum amount Maya can spend in 30 days.',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBudgetCard(
                      title: 'Auto-Release',
                      icon: Icons.autorenew,
                      amount: '2,000',
                      description: 'Allowance automatically sent based on frequency.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFrequencyPicker(),
              const SizedBox(height: 48),
              _buildPrimaryAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: emerald100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: emerald900,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: emerald900,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Found Maya',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: emerald900,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Configure her account settings below',
          style: TextStyle(fontSize: 14, color: stone500),
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEPENDANT TITLE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: stone400,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip('Child', isSelected: true),
              _buildRoleChip('Spouse'),
              _buildRoleChip('Parent'),
              _buildRoleChip('Other'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? emerald900 : stone100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? stone50 : stone800.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required IconData icon,
    required String amount,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: emerald800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: stone400,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'PKR ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: stone400,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: amount),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: emerald900,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: stone400,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyPicker() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: stone800,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: emerald400, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'FREQUENCY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const Text(
                'Every Saturday',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: emerald400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayIndicator('M', false),
              _buildDayIndicator('T', false),
              _buildDayIndicator('W', false),
              _buildDayIndicator('T', false),
              _buildDayIndicator('F', false),
              _buildDayIndicator('S', true),
              _buildDayIndicator('S', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(String day, bool isSelected) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? stone50 : stone500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: isSelected ? 8 : 6,
          width: isSelected ? 8 : 6,
          decoration: BoxDecoration(
            color: isSelected ? emerald400 : Colors.white24,
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: emerald400.withOpacity(0.6),
                      blurRadius: 8,
                    )
                  ]
                : [],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryAction() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: emerald900,
            foregroundColor: stone50,
            elevation: 8,
            shadowColor: emerald900.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Invite to Family',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.send, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'An invitation will be sent to Maya\'s registered phone number for confirmation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: stone400,
            ),
          ),
        ),
      ],
    );
  }
}