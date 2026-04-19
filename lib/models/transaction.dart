import 'expense_category.dart';

/// In-memory mirror of a row from `public.transactions`.
///
/// Money is stored as `BigInt` minor units — never `double`. Use
/// `Money.format` from `lib/models/money.dart` for display.
///
/// Two flavours of row coexist in this table, distinguished by [kind]:
///   * `'transfer'` — peer-to-peer family transfer. Both [senderId] and
///     [receiverId] are non-null. [description] / [category] are null.
///   * `'expense'` — outside-the-family spend logged via the `log_expense`
///     RPC ("PlayStation Network", "Uber", ...). [receiverId] is null;
///     [description] and [category] are non-null.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.familyId,
    required this.senderId,
    required this.receiverId,
    required this.amountMinor,
    required this.createdAt,
    this.kind = 'transfer',
    this.description,
    this.category,
  });

  final String id;
  final String familyId;
  final String senderId;
  final String? receiverId;
  final BigInt amountMinor;
  final DateTime createdAt;

  /// `'transfer'` or `'expense'`. Defaults to `'transfer'` for legacy rows
  /// inserted before the migration added the column.
  final String kind;

  /// Free-text label entered by the user. Always non-null on `expense` rows,
  /// always null on `transfer` rows.
  final String? description;

  /// Snake-case category value from the server. Convert with
  /// [ExpenseCategory.fromServer] for display.
  final String? category;

  bool get isExpense => kind == 'expense';

  /// Parses [category] (always non-null in practice for expense rows, but
  /// falls back to [ExpenseCategory.other] for safety).
  ExpenseCategory get categoryEnum => ExpenseCategory.fromServer(category);

  /// Signed amount from [perspectiveUserId]'s point of view.
  /// Positive when the user received money, negative when they sent it.
  /// Expenses are always negative for the sender (no receiver exists).
  BigInt signedAmountFor(String perspectiveUserId) {
    if (receiverId == perspectiveUserId) return amountMinor;
    if (senderId == perspectiveUserId) return -amountMinor;
    return BigInt.zero;
  }

  /// True if the user was the sender (i.e. money flowed out of their
  /// account). Always true on expense rows for the spender.
  bool isOutgoingFor(String userId) => senderId == userId;

  /// The other party's user id (whoever wasn't [perspectiveUserId]).
  /// Returns `null` for expenses (no in-family counterparty) or when the
  /// perspective user is unrelated to the row.
  String? counterpartyFor(String perspectiveUserId) {
    if (isExpense) return null;
    if (senderId == perspectiveUserId) return receiverId;
    return senderId;
  }

  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String?,
      amountMinor: _readBigInt(map['amount']),
      createdAt: DateTime.parse(map['created_at'] as String),
      kind: (map['kind'] as String?) ?? 'transfer',
      description: map['description'] as String?,
      category: map['category'] as String?,
    );
  }

  static BigInt _readBigInt(Object? raw) {
    if (raw is BigInt) return raw;
    if (raw is int) return BigInt.from(raw);
    if (raw is String) return BigInt.tryParse(raw) ?? BigInt.zero;
    return BigInt.zero;
  }
}
