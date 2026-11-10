import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

enum _TaskFilter {
  all,
  notStarted,
  inProgress,
  completed,
  expired,
}

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyTasksView();
  }
}

class _MyTasksView extends StatefulWidget {
  const _MyTasksView();

  @override
  State<_MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends State<_MyTasksView> {
  _TaskFilter _selectedFilter = _TaskFilter.all;

  Timer? _expiryTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<TaskProvider>().getAssignedTasks(userId: user.id);
      }
    });

    // Refresh the displayed filters when a task deadline passes.
    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final user = context.read<AuthProvider>().user;

    if (user == null) return;

    await context.read<TaskProvider>().getAssignedTasks(userId: user.id);

    if (mounted) {
      setState(() => _now = DateTime.now());
    }
  }

  bool _isExpired(TaskEntity task) {
    return !task.isCompleted &&
        task.dueDate != null &&
        !_now.isBefore(task.dueDate!);
  }

  bool _matchesFilter(TaskEntity task) {
    switch (_selectedFilter) {
      case _TaskFilter.all:
        return true;

      case _TaskFilter.notStarted:
        return !task.isCompleted &&
            !_isExpired(task) &&
            task.progressStatus == TaskProgressStatus.notStarted;

      case _TaskFilter.inProgress:
        return !task.isCompleted &&
            !_isExpired(task) &&
            task.progressStatus == TaskProgressStatus.inProgress;

      case _TaskFilter.completed:
        return task.isCompleted;

      case _TaskFilter.expired:
        return _isExpired(task);
    }
  }

  String _filterLabel(_TaskFilter filter) {
    switch (filter) {
      case _TaskFilter.all:
        return 'All';
      case _TaskFilter.notStarted:
        return 'Not Started';
      case _TaskFilter.inProgress:
        return 'In Progress';
      case _TaskFilter.completed:
        return 'Completed';
      case _TaskFilter.expired:
        return 'Expired';
    }
  }

  int _filterCount(List<TaskEntity> tasks, _TaskFilter filter) {
    if (filter == _TaskFilter.all) return tasks.length;

    return tasks.where((task) {
      switch (filter) {
        case _TaskFilter.all:
          return true;
        case _TaskFilter.notStarted:
          return !task.isCompleted &&
              !_isExpired(task) &&
              task.progressStatus == TaskProgressStatus.notStarted;
        case _TaskFilter.inProgress:
          return !task.isCompleted &&
              !_isExpired(task) &&
              task.progressStatus == TaskProgressStatus.inProgress;
        case _TaskFilter.completed:
          return task.isCompleted;
        case _TaskFilter.expired:
          return _isExpired(task);
      }
    }).length;
  }

  Future<void> _startTask(TaskEntity task) async {
    final provider = context.read<TaskProvider>();

    final success = await provider.startTask(
      projectId: task.projectId,
      taskId: task.id,
    );

    if (!mounted || success) return;

    _showActionError(provider);
  }

  Future<void> _completeTask(TaskEntity task) async {
    final provider = context.read<TaskProvider>();

    final success = await provider.toggleTaskCompletion(
      projectId: task.projectId,
      taskId: task.id,
      isCompleted: task.isCompleted,
      updateProjectStats: false,
    );

    if (!mounted || success) return;

    _showActionError(provider);
  }

  void _showActionError(TaskProvider provider) {
    final message = provider.actionErrorMessage;

    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final tasks = provider.tasks;

            final completedCount =
                tasks.where((task) => task.isCompleted).length;

            final pendingCount = tasks.length - completedCount;

            final filteredTasks = tasks.where(_matchesFilter).toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              color: colors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: _TasksHeader(
                        totalTasks: tasks.length,
                        completedTasks: completedCount,
                        pendingTasks: pendingCount,
                      ),
                    ),
                  ),

                  if (provider.isLoading && tasks.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (provider.status == TaskStatus.failure &&
                      tasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _TasksMessage(
                        message:
                        provider.errorMessage ?? 'Failed to load tasks.',
                        icon: Icons.error_outline_rounded,
                        actionLabel: 'Try again',
                        onAction: _refresh,
                      ),
                    )
                  else if (tasks.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _TasksEmptyView(),
                      )
                    else ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Text(
                                  'Assigned to me',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${tasks.length} tasks',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Task status filters.
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                          sliver: SliverToBoxAdapter(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _TaskFilter.values.map((filter) {
                                final selected = _selectedFilter == filter;
                                final count = _filterCount(tasks, filter);

                                return ChoiceChip(
                                  selected: selected,
                                  showCheckmark: false,
                                  label: Text(
                                    '${_filterLabel(filter)} ($count)',
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                                    color: selected
                                        ? colors.onPrimary
                                        : colors.onSurfaceVariant,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  selectedColor: colors.primary,
                                  backgroundColor: colors.surface,
                                  side: BorderSide(
                                    color: selected
                                        ? colors.primary
                                        : colors.outlineVariant,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 7,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        if (filteredTasks.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_list_off_rounded,
                                      size: 42,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No ${_filterLabel(_selectedFilter).toLowerCase()} tasks',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'There are no tasks matching this filter.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  final task = filteredTasks[index];

                                  final isActionLoading =
                                      provider.actionTaskId == task.id &&
                                          provider.actionStatus ==
                                              TaskActionStatus.loading;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: TaskCard(
                                      task: task,
                                      isActionLoading: isActionLoading,
                                      showActions: false,
                                      onStart: () => _startTask(task),
                                      onComplete: () => _completeTask(task),
                                    ),
                                  );
                                },
                                childCount: filteredTasks.length,
                              ),
                            ),
                          ),
                      ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  const _TasksHeader({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.checklist_rounded,
                color: colors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tasks',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Keep track of your work and progress',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colors.surfaceContainerHighest,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _TaskStat(
                      label: 'Total',
                      value: totalTasks,
                      icon: Icons.assignment_outlined,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TaskStat(
                      label: 'Pending',
                      value: pendingTasks,
                      icon: Icons.pending_actions_rounded,
                      color: colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TaskStat(
                      label: 'Completed',
                      value: completedTasks,
                      icon: Icons.task_alt_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _TaskStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksEmptyView extends StatelessWidget {
  const _TasksEmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 44,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'All clear for now!',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don’t have any tasks assigned to you yet. '
                  'Your tasks will appear here when they are assigned.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Ready for new tasks'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TasksMessage({
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 36,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}