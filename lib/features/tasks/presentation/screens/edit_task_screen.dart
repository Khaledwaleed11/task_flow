import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/presentation/providers/admin_user_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/edit_task_information_card.dart';
import '../widgets/edit_task_priority_selector.dart';
import '../widgets/save_task_button.dart';

class EditTaskScreen extends StatefulWidget {
  final String projectId;
  final TaskEntity task;

  const EditTaskScreen({
    super.key,
    required this.projectId,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late TaskPriority _selectedPriority;

  String? _selectedUserId;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);

    _descriptionController = TextEditingController(
      text: widget.task.description,
    );

    _selectedPriority = widget.task.priority;
    _selectedUserId = widget.task.assignedUserId;

    _descriptionController.addListener(_onDescriptionChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
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

  void _onDescriptionChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();

    _descriptionController
      ..removeListener(_onDescriptionChanged)
      ..dispose();

    _animationController.dispose();

    super.dispose();
  }

  Future<void> _updateTask() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<TaskProvider>();

    final success = await provider.updateTask(
      projectId: widget.projectId,
      taskId: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      assignedUserId: _selectedUserId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      return;
    }

    final message = provider.actionErrorMessage ?? 'Failed to update task';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final userProvider = context.watch<AdminUserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopBar(
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 28),
                        const _HeroHeader(),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.1 : 0.025,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _SectionLabel(
                                icon: Icons.edit_note_rounded,
                                title: 'Task information',
                                subtitle: 'Update the details of this task.',
                              ),
                              const SizedBox(height: 20),
                              EditTaskInformationCard(
                                titleController: _titleController,
                                descriptionController: _descriptionController,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${_descriptionController.text.length}/500',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _SectionLabel(
                                icon: Icons.tune_rounded,
                                title: 'Task settings',
                                subtitle: 'Update priority and assignment.',
                              ),
                              const SizedBox(height: 20),
                              EditTaskPrioritySelector(
                                selectedPriority: _selectedPriority,
                                onChanged: (priority) {
                                  setState(() {
                                    _selectedPriority = priority;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildAssignmentSelector(userProvider),
                              const SizedBox(height: 20),
                              _buildCompletionStatus(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft.withValues(
                              alpha: isDark ? 0.08 : 0.55,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Task completion is managed by the assigned user and cannot be changed here.',
                                  style: AppTextStyles.bodySecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SaveTaskButton(
                          isLoading: taskProvider.isActionLoading,
                          onPressed: _updateTask,
                        ),
                        const SizedBox(height: 16),
                        const _SecurityFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentSelector(AdminUserProvider provider) {
    final usersById = <String, dynamic>{};

    for (final user in provider.assignableUsers) {
      usersById[user.id] = user;
    }

    final users = usersById.values.toList();

    final hasSelectedUser =
        _selectedUserId != null &&
        users.any((user) => user.id == _selectedUserId);

    final dropdownValue = hasSelectedUser ? _selectedUserId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assignment', style: AppTextStyles.title),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          initialValue: dropdownValue,
          decoration: const InputDecoration(
            labelText: 'Assign to',
            hintText: 'Select a user',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No assignment'),
            ),
            ...users.map((user) {
              return DropdownMenuItem<String?>(
                value: user.id,
                child: Text(user.email, overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: users.isNotEmpty
              ? (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                }
              : null,
        ),
        if (provider.status == AdminUserStatus.loading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (!provider.hasAssignableUsers &&
            provider.status == AdminUserStatus.loaded) ...[
          const SizedBox(height: 12),
          const _AssignmentHint(),
        ],
      ],
    );
  }

  Widget _buildCompletionStatus() {
    final isCompleted = widget.task.isCompleted;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isCompleted ? AppColors.success : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Completion Status', style: AppTextStyles.title),
                const SizedBox(height: 3),
                Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: isCompleted ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? AppColors.darkSurface : AppColors.border,
              ),
            ),
            child: const Text('Read only', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
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
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Task', style: AppTextStyles.title),
              SizedBox(height: 2),
              Text(
                'Update this task and keep your project organized',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 18),
        const Text(
          'Refine your task',
          textAlign: TextAlign.center,
          style: AppTextStyles.display,
        ),
        const SizedBox(height: 7),
        Text(
          'Update the details and keep everything on track.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssignmentHint extends StatelessWidget {
  const _AssignmentHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 17, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No users are currently available for assignment.',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          'Your task changes are securely stored.',
          style: AppTextStyles.caption.copyWith(fontSize: 10.5),
        ),
      ],
    );
  }
}
