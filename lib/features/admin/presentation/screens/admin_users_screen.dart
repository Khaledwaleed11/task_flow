import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                        AdminUsersTopBar(
                          userCount: provider.users.length,
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 28),
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
                                  const SizedBox(height: 14),
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
}
