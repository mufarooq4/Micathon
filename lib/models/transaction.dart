/// In-memory mirror of a row from `public.transactions`.
///
/// Money is stored as `BigInt` minor units — never `double`. Use
/// `Money.format` from `lib/models/money.dart` for display.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.familyId,
    required this.senderId,
    required this.receiverId,
    required this.amountMinor,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String senderId;
  final String receiverId;
  final BigInt amountMinor;
  final DateTime createdAt;

  /// Signed amount from [perspectiveUserId]'s point of view.
  /// Positive when the user received money, negative when they sent it.
  BigInt signedAmountFor(String perspectiveUserId) {
    if (receiverId == perspectiveUserId) return amountMinor;
    if (senderId == perspectiveUserId) return -amountMinor;
    return BigInt.zero;
  }

  /// True if the user was the sender (i.e. money flowed out of their account).
  bool isOutgoingFor(String userId) => senderId == userId;

  /// The other party's user id (whoever wasn't [perspectiveUserId]).
  /// Falls back to receiver if the perspective user is unrelated.
  String counterpartyFor(String perspectiveUserId) {
    if (senderId == perspectiveUserId) return receiverId;
    return senderId;
  }

  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      amountMinor: _readBigInt(map['amount']),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static BigInt _readBigInt(Object? raw) {
    if (raw is BigInt) return raw;
    if (raw is int) return BigInt.from(raw);
    if (raw is String) return BigInt.tryParse(raw) ?? BigInt.zero;
    return BigInt.zero;
  }
}
