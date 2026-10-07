import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'User not found.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
      ProfileProvider(updateProfileImageUseCase: sl())..setUser(user),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null || !context.mounted) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return;
    }

    final profileProvider = context.read<ProfileProvider>();

    final success = await profileProvider.updateProfileImage(
      userId: user.id,
      filePath: image.path,
    );

    if (!context.mounted) {
      return;
    }

    if (success && profileProvider.user != null) {
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile image updated successfully.',
          ),
        ),
      );
    } else if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profileProvider.errorMessage ??
                'Failed to update profile image.',
          ),
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          authProvider.errorMessage ?? 'Failed to logout.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final user = profileProvider.user;

        if (user == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                32,
              ),
              child: Column(
                children: [
                  ProfileHeader(
                    user: user,
                    isLoading: profileProvider.isLoading,
                    onPickImage: () => _pickImage(context),
                  ),

                  const SizedBox(height: 28),

                  ProfileInfoCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Name',
                    value: user.name,
                  ),

                  const SizedBox(height: 12),

                  ProfileInfoCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                  ),

                  const SizedBox(height: 12),

                  ProfileInfoCard(
                    icon: user.role == UserRole.admin
                        ? Icons.admin_panel_settings_outlined
                        : Icons.person_outline_rounded,
                    title: 'Role',
                    value: user.role == UserRole.admin
                        ? 'Administrator'
                        : 'User',
                  ),

                  const SizedBox(height: 12),

                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      final isDark =
                          themeProvider.themeMode == ThemeMode.dark;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: colorScheme.primary,
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appearance',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isDark
                                        ? 'Dark Mode'
                                        : 'Light Mode',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color:
                                      colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Switch(
                              value: isDark,
                              onChanged: (_) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap the camera button to change your profile picture.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                      ),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(
                          color: colorScheme.error.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}