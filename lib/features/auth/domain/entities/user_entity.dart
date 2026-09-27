enum UserRole { user, admin }

class UserEntity {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
}
