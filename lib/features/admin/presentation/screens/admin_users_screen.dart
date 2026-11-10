import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/admin_user_provider.dart';
import '../widgets/admin_user_card.dart';
import '../widgets/admin_users_empty_state.dart';
import '../widgets/admin_users_error_state.dart';
import '../widgets/admin_users_loading_state.dart';
import '../widgets/admin_users_overview.dart';
import '../widgets/admin_users_section_header.dart';
import '../widgets/admin_users_top_bar.dart';

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
      if (!mounted) return;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Consumer<AdminUserProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AdminUsersTopBar(
                          userCount: provider.users.length,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 24),

                        _buildHeroCard(
                          context,
                          userCount: provider.users.length,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 26),

                        if (provider.status == AdminUserStatus.loading)
                          const AdminUsersLoadingState()
                        else if (provider.status == AdminUserStatus.failure)
                          AdminUsersErrorState(
                            message:
                                provider.errorMessage ??
                                'Something went wrong.',
                            onRetry: provider.getUsers,
                          )
                        else if (!provider.hasUsers)
                          const AdminUsersEmptyState()
                        else
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AdminUsersOverview(provider: provider),
                                  const SizedBox(height: 28),
                                  const AdminUsersSectionHeader(),
                                  const SizedBox(height: 16),
                                  ...provider.users.map(
                                    (user) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: AdminUserCard(user: user),
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

  Widget _buildHeroCard(
    BuildContext context, {
    required int userCount,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF087F8C), Color(0xFF075E68)]
              : const [Color(0xFF0B8995), Color(0xFF066570)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -22,
            child: Icon(
              Icons.groups_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Your Team',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Manage your team members and keep everyone connected.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFFFB15C),
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      '$userCount ${userCount == 1 ? 'Member' : 'Members'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
