import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool isLoading;
  final VoidCallback onPickImage;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isLoading,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imageUrl = user.profileImageUrl;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                border: Border.all(
                  color: colorScheme.primary.withValues(
                    alpha: 0.18,
                  ),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Icon(
                      Icons.person_rounded,
                      color: colorScheme.primary,
                      size: 58,
                    );
                  },
                )
                    : Icon(
                  Icons.person_rounded,
                  color: colorScheme.primary,
                  size: 58,
                ),
              ),
            ),

            GestureDetector(
              onTap: isLoading ? null : onPickImage,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: isLoading
                    ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
                    : Icon(
                  Icons.camera_alt_rounded,
                  color: colorScheme.onPrimary,
                  size: 19,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          user.name.isEmpty ? 'User' : user.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          user.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}