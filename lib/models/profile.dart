/// User role as stored in the `public.user_role` Postgres enum.
///
/// Mirrors the values: `'pending'`, `'child'`, `'parent'`.
enum UserRole {
  pending,
  child,
  parent,
  unknown;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'pending':
        return UserRole.pending;
      case 'child':
        return UserRole.child;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.unknown;
    }
  }
}

/// In-memory representation of a row from `public.profiles`.
///
/// Money fields (`balance`) are stored in minor units (e.g. paisas) as a
/// `BigInt` mirror of the Postgres `BIGINT`. Never do arithmetic on this
/// client-side beyond display formatting — all transfers go through RPCs.
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.familyId,
    required this.balanceMinor,
    required this.dateOfBirth,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? familyId;
  final BigInt balanceMinor;
  final DateTime? dateOfBirth;

  bool get isOnboarded => familyId != null && role != UserRole.pending;

  factory Profile.fromMap(Map<String, dynamic> map) {
    final dobRaw = map['date_of_birth'];
    DateTime? dob;
    if (dobRaw is String && dobRaw.isNotEmpty) {
      dob = DateTime.tryParse(dobRaw);
    }

    final balanceRaw = map['balance'];
    BigInt balance;
    if (balanceRaw is BigInt) {
      balance = balanceRaw;
    } else if (balanceRaw is int) {
      balance = BigInt.from(balanceRaw);
    } else if (balanceRaw is String) {
      balance = BigInt.tryParse(balanceRaw) ?? BigInt.zero;
    } else {
      balance = BigInt.zero;
    }

    return Profile(
      id: map['id'] as String,
      fullName: (map['full_name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: UserRole.fromString(map['role'] as String?),
      familyId: map['family_id'] as String?,
      balanceMinor: balance,
      dateOfBirth: dob,
    );
  }
}
