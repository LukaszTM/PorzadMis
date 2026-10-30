enum Role {
  admin,
  member;

  static Role parse(Object? value) => value == 'admin' ? Role.admin : Role.member;
}

class UserProfile {
  const UserProfile({
    this.displayName,
    this.householdId,
    this.themeId,
    this.themeMode = 'auto',
    this.onboardingDone = false,
  });

  final String? displayName;
  final String? householdId;

  /// Motyw i tryb wybrane przez użytkownika (działają na każdym telefonie po zalogowaniu).
  final String? themeId;
  final String themeMode;
  final bool onboardingDone;

  factory UserProfile.fromMap(Map<String, dynamic>? data) => UserProfile(
        displayName: data?['displayName'] as String?,
        householdId: data?['householdId'] as String?,
        themeId: data?['themeId'] as String?,
        themeMode: (data?['themeMode'] as String?) ?? 'auto',
        onboardingDone: data?['onboardingDone'] == true,
      );
}

class Household {
  const Household({required this.id, required this.name});

  final String id;
  final String name;
}

class Member {
  const Member({required this.uid, required this.displayName, required this.role});

  final String uid;
  final String displayName;
  final Role role;

  bool get isAdmin => role == Role.admin;

  factory Member.fromMap(String uid, Map<String, dynamic> data) => Member(
        uid: uid,
        displayName: (data['displayName'] as String?) ?? '',
        role: Role.parse(data['role']),
      );
}

class Invite {
  const Invite({
    required this.code,
    required this.qrToken,
    required this.expiresAt,
    required this.multiUse,
    required this.revoked,
    required this.usedBy,
  });

  final String code;
  final String qrToken;
  final DateTime expiresAt;
  final bool multiUse;
  final bool revoked;
  final List<String> usedBy;

  /// Treść kodu QR: tylko identyfikator zaproszenia (PLAN.md).
  String get qrPayload => '$qrPrefix$qrToken';

  static const qrPrefix = 'porzadmis:join:';

  /// Zwraca token z treści QR albo null, gdy to nie kod PorządMisia.
  static String? tokenFromQr(String? raw) {
    if (raw == null || !raw.startsWith(qrPrefix)) return null;
    final token = raw.substring(qrPrefix.length).trim();
    return token.isEmpty ? null : token;
  }
}
