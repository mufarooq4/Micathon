import 'profile.dart';

/// In-memory representation of a row from `public.invitations` as returned
/// by the `create_invitation` RPC.
///
/// The raw [code] is the 8-char alphanumeric (no dashes). For UI display we
/// format it as `XXXX-XXXX` via [formattedCode]; for clipboard / sharing we
/// also use the formatted version because users will type the dash anyway.
/// `redeem_invitation` accepts both forms — see [normaliseCode].
class Invitation {
  const Invitation({
    required this.id,
    required this.code,
    required this.roleOffered,
    required this.expiresAt,
  });

  final String id;
  final String code;
  final UserRole roleOffered;
  final DateTime expiresAt;

  /// `XXXX-XXXX` view of [code]. If the code length is something other than
  /// 8 chars (defensive), we just return it unchanged.
  String get formattedCode {
    if (code.length != 8) return code;
    return '${code.substring(0, 4)}-${code.substring(4)}';
  }

  /// Strips formatting (dashes, spaces) and uppercases. Use before sending
  /// a user-typed code to `redeem_invitation` so "abcd-1234" and "ABCD1234"
  /// both work.
  static String normaliseCode(String input) {
    return input.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  }

  factory Invitation.fromMap(Map<String, dynamic> map) {
    final expiresRaw = map['expires_at'];
    DateTime expires;
    if (expiresRaw is DateTime) {
      expires = expiresRaw;
    } else if (expiresRaw is String) {
      expires = DateTime.parse(expiresRaw);
    } else {
      expires = DateTime.now();
    }
    return Invitation(
      id: map['id'] as String,
      code: (map['code'] as String?) ?? '',
      roleOffered: UserRole.fromString(map['role_offered'] as String?),
      expiresAt: expires,
    );
  }
}
