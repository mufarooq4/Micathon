/// Helpers for working with money values stored as `BIGINT` minor units in
/// Postgres (paisas in our case — 1 PKR = 100 paisas).
///
/// Never do arithmetic on user-facing display strings. Use these helpers to
/// convert at the UI boundary only; all real math happens server-side inside
/// `transfer_money` / `act_on_request`.
class Money {
  Money._();

  static const int _minorPerMajor = 100;

  /// `4250` (paisa) → `'PKR 42.50'`. Negative values are rendered with a
  /// leading minus sign.
  static String format(BigInt minor, {String currency = 'PKR'}) {
    final negative = minor.isNegative;
    final abs = negative ? -minor : minor;
    final whole = abs ~/ BigInt.from(_minorPerMajor);
    final frac = abs % BigInt.from(_minorPerMajor);
    final fracStr = frac.toString().padLeft(2, '0');
    final wholeStr = _withThousandsSeparators(whole.toString());
    return '${negative ? '-' : ''}$currency $wholeStr.$fracStr';
  }

  /// Same as [format] but for `int` callers — useful when the source is an
  /// already-narrowed `int`.
  static String formatInt(int minor, {String currency = 'PKR'}) =>
      format(BigInt.from(minor), currency: currency);

  /// Parses a user-typed amount (e.g. `'42.50'`, `'42'`, `'42.5'`) into
  /// minor-unit `BigInt`. Returns `null` on parse failure or non-positive.
  static BigInt? parseMajorToMinor(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final m = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(trimmed);
    if (m == null) return null;
    final whole = BigInt.parse(m.group(1)!);
    final fracStr = (m.group(2) ?? '').padRight(2, '0');
    final frac = BigInt.parse(fracStr.isEmpty ? '0' : fracStr);
    final result = whole * BigInt.from(_minorPerMajor) + frac;
    if (result <= BigInt.zero) return null;
    return result;
  }

  static String _withThousandsSeparators(String n) {
    final buf = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) buf.write(',');
      buf.write(n[i]);
    }
    return buf.toString();
  }
}
