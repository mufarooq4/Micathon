import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(const SendMoneyApp());
// }

// Color palette consistent with previous screens
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

class SendMoneyApp extends StatelessWidget {
  const SendMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send Money',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const SendMoneyScreen(),
    );
  }
}

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the amount field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _addQuickAmount(int amount) {
    setState(() {
      // Simple logic to replace or add to the current amount
      _amountController.text = amount.toString();
      // Move cursor to the end
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildRecipientPill(),
                    const SizedBox(height: 48),
                    _buildAmountInput(),
                    const SizedBox(height: 32),
                    _buildQuickAmountChips(),
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
      backgroundColor: AppColors.background.withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.onSurface),
        onPressed: () {
          // Navigation pop logic would go here
        },
      ),
      title: const Text(
        'Send Money',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
          const Text(
            'To:',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF46654F),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'D', // Initial for Dad
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Dad',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        const Text(
          'ENTER AMOUNT',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicWidth(
          child: TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -2.0,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                color: AppColors.surfaceContainerHighest,
              ),
              prefixText: 'Rs. ',
              prefixStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(500),
        const SizedBox(width: 12),
        _buildChip(1000),
        const SizedBox(width: 12),
        _buildChip(5000),
      ],
    );
  }

  Widget _buildChip(int amount) {
    return ActionChip(
      onPressed: () => _addQuickAmount(amount),
      backgroundColor: AppColors.surfaceContainerLowest,
      side: const BorderSide(color: AppColors.surfaceContainerHighest),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      label: Text(
        '+$amount',
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainerHighest.withOpacity(0.5)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.edit_note, color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          hintText: 'What\'s this for? (Optional)',
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainerHighest.withOpacity(0.5)),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Send action logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Send Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
              _buildNavItem(Icons.account_tree, 'Tree', true), // Highlighted context
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