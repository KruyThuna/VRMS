import '../auth/user_role.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.guest,
    this.avatarUrl,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager || role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatarUrl': avatarUrl,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == (j['role'] as String?),
          orElse: () => UserRole.guest,
        ),
        avatarUrl: j['avatarUrl'] as String?,
      );

  static const AppUser adminDefault = AppUser(
    id: 'usr_admin',
    name: 'DriveLine Administrator',
    email: 'admin@driveline.pk',
    role: UserRole.admin,
  );

  static const AppUser guestDefault = AppUser(
    id: 'usr_guest',
    name: 'Guest Client',
    email: 'guest@driveline.pk',
    role: UserRole.guest,
  );
}

