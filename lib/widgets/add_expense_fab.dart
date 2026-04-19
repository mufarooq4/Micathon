import 'package:flutter/material.dart';

import '../screens/add_expense_screen.dart';

/// Floating action button shared by `ChildHome` and `ParentHome`. Tapping
/// opens [AddExpenseScreen] on the root navigator so it sits over the
/// bottom navigation bar instead of inside it.
///
/// Uses a stable [heroTag] so both home screens can be in the navigator
/// stack at the same time without Hero collisions.
class AddExpenseFab extends StatelessWidget {
  const AddExpenseFab({super.key});

  static const Color _green = Color(0xFF006B3C);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'add-expense-fab',
      tooltip: 'Add expense',
      backgroundColor: _green,
      foregroundColor: Colors.white,
      elevation: 4,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        );
      },
      child: const Icon(Icons.add, size: 28),
    );
  }
}
