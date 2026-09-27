import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/admin_user_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final provider = context.read<AdminUserProvider>();

      if (provider.status == AdminUserStatus.initial) {
        provider.getUsers();
      }
    });
  }

  Future<void> _refresh() async {
    await context.read<AdminUserProvider>().getUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AdminUserProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _UsersTopBar(
                          userCount: provider.users.length,
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 28),
                        if (provider.status == AdminUserStatus.loading)
                          const _LoadingState()
                        else if (provider.status == AdminUserStatus.failure)
                          _ErrorState(
                            message:
                                provider.errorMessage ??
                                'Something went wrong.',
                            onRetry: provider.getUsers,
                          )
                        else if (!provider.hasUsers)
                          const _EmptyState()
                        else
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _UsersOverview(provider: provider),
                                  const SizedBox(height: 28),
                                  const _SectionHeader(),
                                  const SizedBox(height: 14),
                                  ...provider.users.map(
                                    (user) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _UserCard(user: user),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UsersTopBar extends StatelessWidget {
  final int userCount;
  final VoidCallback onBack;

  const _UsersTopBar({required this.userCount, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: AppColors.textPrimary,
                fixedSize: const Size(44, 44),
                side: BorderSide(
                  color: isDark ? AppColors.darkSurface : AppColors.border,
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Users', style: AppTextStyles.display),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              userCount == 0
                  ? 'Manage your workspace members'
                  : '$userCount ${userCount == 1 ? 'member' : 'members'} in your workspace',
              style: AppTextStyles.bodySecondary,
            ),
            if (userCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text('Workspace', style: AppTextStyles.caption),
            ],
          ],
        ),
      ],
    );
  }
}

class _UsersOverview extends StatelessWidget {
  final AdminUserProvider provider;

  const _UsersOverview({required this.provider});

  @override
  Widget build(BuildContext context) {
    final adminCount = provider.users
        .where((user) => user.role == UserRole.admin)
        .length;

    final userCount = provider.users
        .where((user) => user.role == UserRole.user)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace members',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'A quick overview of your team',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  value: '${provider.users.length}',
                  label: 'Total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewMetric(value: '$userCount', label: 'Users'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewMetric(value: '$adminCount', label: 'Admins'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Members', style: AppTextStyles.headline),
        SizedBox(height: 4),
        Text(
          'People with access to your workspace',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserEntity user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == UserRole.admin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = user.name.trim().isEmpty ? 'Unnamed User' : user.name.trim();

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final roleColor = isAdmin ? AppColors.primary : AppColors.success;

    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkSurface : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primarySoft : AppColors.background,
                borderRadius: BorderRadius.circular(17),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: roleColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoleBadge(isAdmin: isAdmin),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const _RoleBadge({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final color = isAdmin ? AppColors.primary : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 29,
            ),
          ),
          const SizedBox(height: 18),
          const Text('Unable to load users', style: AppTextStyles.title),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 130,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: AppColors.primary,
              size: 35,
            ),
          ),
          const SizedBox(height: 20),
          const Text('No users found', style: AppTextStyles.title),
          const SizedBox(height: 7),
          const Text(
            'There are no registered users in your workspace yet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}
