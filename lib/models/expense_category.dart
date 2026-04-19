import 'package:flutter/material.dart';

/// Single source of truth for the categories an expense can belong to.
///
/// The string values returned by [serverValue] MUST stay in lockstep with
/// the `transactions_category_check` and the validation inside the
/// `log_expense(...)` RPC. If you add a value here, add it there too.
enum ExpenseCategory {
  groceries,
  dining,
  entertainment,
  transport,
  shopping,
  bills,
  health,
  education,
  other;

  /// Snake-case wire format that the SQL CHECK constraint accepts.
  String get serverValue => switch (this) {
        ExpenseCategory.groceries => 'groceries',
        ExpenseCategory.dining => 'dining',
        ExpenseCategory.entertainment => 'entertainment',
        ExpenseCategory.transport => 'transport',
        ExpenseCategory.shopping => 'shopping',
        ExpenseCategory.bills => 'bills',
        ExpenseCategory.health => 'health',
        ExpenseCategory.education => 'education',
        ExpenseCategory.other => 'other',
      };

  /// Human-readable label used in chips and ledger rows.
  String get displayName => switch (this) {
        ExpenseCategory.groceries => 'Groceries',
        ExpenseCategory.dining => 'Dining',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.bills => 'Bills',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.education => 'Education',
        ExpenseCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        ExpenseCategory.groceries => Icons.local_grocery_store,
        ExpenseCategory.dining => Icons.restaurant,
        ExpenseCategory.entertainment => Icons.movie,
        ExpenseCategory.transport => Icons.directions_car,
        ExpenseCategory.shopping => Icons.shopping_bag,
        ExpenseCategory.bills => Icons.receipt_long,
        ExpenseCategory.health => Icons.medical_services,
        ExpenseCategory.education => Icons.school,
        ExpenseCategory.other => Icons.category,
      };

  /// Lenient parser. Unknown / null values fall back to [ExpenseCategory.other]
  /// so a malformed row never crashes the ledger.
  static ExpenseCategory fromServer(String? raw) {
    if (raw == null) return ExpenseCategory.other;
    for (final c in ExpenseCategory.values) {
      if (c.serverValue == raw) return c;
    }
    return ExpenseCategory.other;
  }
}
