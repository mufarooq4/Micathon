/// In-memory mirror of a row from `public.dependent_controls`.
///
/// One row per `(family_id, child_id)`. `parent_id` records whichever
/// parent last upserted the row — that parent's balance is the source for
/// the auto-transfer.
///
/// Money is stored as `BigInt` minor units (paisas), never `double`.
class DependentControls {
  const DependentControls({
    required this.familyId,
    required this.childId,
    required this.parentId,
    required this.monthlyLimitMinor,
    required this.autoTransferEnabled,
    required this.autoTransferAmountMinor,
    required this.autoTransferDay,
    required this.lastExecutedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String familyId;
  final String childId;
  final String parentId;

  /// `null` = no monthly cap. When set, the child's month-to-date outgoing
  /// total must stay at-or-below this for any further transfer to clear.
  final BigInt? monthlyLimitMinor;

  final bool autoTransferEnabled;

  /// Required when [autoTransferEnabled] is true; ignored otherwise.
  final BigInt? autoTransferAmountMinor;

  /// 0 = Sunday, 6 = Saturday. Matches Postgres `extract(dow from ...)`.
  final int? autoTransferDay;

  /// Wall-clock of the most recent successful auto-transfer. Used by
  /// `run_due_auto_transfers()` to skip rows that already fired today.
  final DateTime? lastExecutedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convenience: a one-line description of the currently-scheduled
  /// transfer, or `null` if nothing is scheduled.
  String? describeSchedule() {
    if (!autoTransferEnabled) return null;
    final amt = autoTransferAmountMinor;
    final day = autoTransferDay;
    if (amt == null || day == null) return null;
    return 'Every ${_dayName(day)}';
  }

  static String _dayName(int dow) {
    const names = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    if (dow < 0 || dow > 6) return 'Unknown';
    return names[dow];
  }

  factory DependentControls.fromMap(Map<String, dynamic> map) {
    return DependentControls(
      familyId: map['family_id'] as String,
      childId: map['child_id'] as String,
      parentId: map['parent_id'] as String,
      monthlyLimitMinor: _readNullableBigInt(map['monthly_limit_minor']),
      autoTransferEnabled: (map['auto_transfer_enabled'] as bool?) ?? false,
      autoTransferAmountMinor:
          _readNullableBigInt(map['auto_transfer_amount_minor']),
      autoTransferDay: (map['auto_transfer_day'] as num?)?.toInt(),
      lastExecutedAt: _readNullableTs(map['last_executed_at']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static BigInt? _readNullableBigInt(Object? raw) {
    if (raw == null) return null;
    if (raw is BigInt) return raw;
    if (raw is int) return BigInt.from(raw);
    if (raw is String) return BigInt.tryParse(raw);
    return null;
  }

  static DateTime? _readNullableTs(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
