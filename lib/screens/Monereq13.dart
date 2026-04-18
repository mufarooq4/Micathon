import 'package:flutter/material.dart';
import 'package:micathon/screens/childhome5.dart';
import 'package:micathon/screens/child_activity6.dart';
import 'package:micathon/screens/child_view_of_family_tree7.dart';
import 'package:micathon/screens/settings_screen.dart';

// void main() {
//   runApp(const RequestMoneyApp());
// }

class AppColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color primary = Color(0xFF00502C);
  static const Color primaryContainer = Color(0xFF006B3C);
  static const Color loanAccent = Color(0xFF3F51B5); // Distinct color for "Borrow"
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF3F4941);
}

class RequestMoneyApp extends StatelessWidget {
  const RequestMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request Money',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Manrope',
        useMaterial3: true,
      ),
      home: const RequestMoneyScreen(),
    );
  }
}

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  
  // 0 = Request Money, 1 = Borrow (Loan)
  int _requestTypeIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildRecipientPill(),
                    const SizedBox(height: 32),
                    
                    // NEW: Toggle between Request and Borrow
                    _buildRequestTypeToggle(),
                    
                    const SizedBox(height: 40),
                    _buildAmountInput(),
                    const SizedBox(height: 48),
                    _buildNoteInput(),
                  ],
                ),
              ),
            ),
            _buildBottomActionArea(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Request Funds', 
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
    );
  }

  Widget _buildRecipientPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Requesting from:', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFF46654F),
            child: Text('D', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          const Text('Dad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRequestTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleItem('Request Money', 0)),
          Expanded(child: _buildToggleItem('Borrow (Loan)', 1)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, int index) {
    bool isSelected = _requestTypeIndex == index;
    Color activeColor = index == 0 ? AppColors.primary : AppColors.loanAccent;

    return GestureDetector(
      onTap: () => setState(() => _requestTypeIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        Text(
          _requestTypeIndex == 0 ? 'HOW MUCH DO YOU NEED?' : 'HOW MUCH TO BORROW?',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        IntrinsicWidth(
          child: TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56, 
              fontWeight: FontWeight.w800, 
              color: _requestTypeIndex == 0 ? AppColors.primary : AppColors.loanAccent,
              letterSpacing: -2.0,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: const TextStyle(color: AppColors.surfaceContainerHighest),
              prefixText: 'Rs. ',
              prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _requestTypeIndex == 0 ? AppColors.primary : AppColors.loanAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHighest.withOpacity(0.5)),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.description_outlined, color: AppColors.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          hintText: _requestTypeIndex == 0 ? 'Reason for request' : 'Why do you need this loan?',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildBottomActionArea() {
    bool isLoan = _requestTypeIndex == 1;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHighest.withOpacity(0.5))),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoan ? AppColors.loanAccent : AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          isLoan ? 'Request Loan' : 'Send Request',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, -20))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, tabIndex: 0),
              _buildNavItem(Icons.history, 'Activity', false, tabIndex: 1),
              _buildNavItem(Icons.account_tree, 'Tree', true, tabIndex: 2),
              _buildNavItem(Icons.settings_outlined, 'Settings', false, tabIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    required int tabIndex,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (isActive) return;
        if (tabIndex == 0) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
            (route) => false,
          );
        } else if (tabIndex == 1) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChildActivityScreen()),
            (route) => false,
          );
        } else if (tabIndex == 2) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChildDashboardScreen()),
            (route) => false,
          );
        } else if (tabIndex == 3) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurface.withOpacity(0.4)),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? AppColors.primary : AppColors.onSurface.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}