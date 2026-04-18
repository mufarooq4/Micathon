/// Mirrors `public.request_status` enum.
enum RequestStatus {
  pending,
  approved,
  declined,
  executed,
  cancelled,
  unknown;

  static RequestStatus fromString(String? raw) {
    switch (raw) {
      case 'pending':
        return RequestStatus.pending;
      case 'approved':
        return RequestStatus.approved;
      case 'declined':
        return RequestStatus.declined;
      case 'executed':
        return RequestStatus.executed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.declined:
        return 'Declined';
      case RequestStatus.executed:
        return 'Executed';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.unknown:
        return 'Unknown';
    }
  }
}

/// In-memory mirror of a row from `public.requests`.
class MoneyRequest {
  const MoneyRequest({
    required this.id,
    required this.familyId,
    required this.requesterId,
    required this.approverId,
    required this.amountMinor,
    required this.status,
    required this.linkedTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String familyId;
  final String requesterId;
  final String? approverId;
  final BigInt amountMinor;
  final RequestStatus status;
  final String? linkedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == RequestStatus.pending;

  factory MoneyRequest.fromMap(Map<String, dynamic> map) {
    return MoneyRequest(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      requesterId: map['requester_id'] as String,
      approverId: map['approver_id'] as String?,
      amountMinor: _readBigInt(map['amount']),
      status: RequestStatus.fromString(map['status'] as String?),
      linkedTransactionId: map['linked_transaction_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static BigInt _readBigInt(Object? raw) {
    if (raw is BigInt) return raw;
    if (raw is int) return BigInt.from(raw);
    if (raw is String) return BigInt.tryParse(raw) ?? BigInt.zero;
    return BigInt.zero;
  }
}
