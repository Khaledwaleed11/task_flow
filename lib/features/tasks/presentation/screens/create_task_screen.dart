import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/presentation/providers/admin_user_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/create_task_assignment_section.dart';
import '../widgets/create_task_button.dart';
import '../widgets/create_task_header.dart';
import '../widgets/edit_task_section_label.dart';
import '../widgets/task_information_card.dart';
import '../widgets/task_priority_selector.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;

  const CreateTaskScreen({super.key, required this.projectId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

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

  Future<void> _createTask() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<TaskProvider>();

    final success = await provider.createTask(
      projectId: widget.projectId,
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

    final message = provider.actionErrorMessage;

    if (message != null) {
      final colorScheme = Theme.of(context).colorScheme;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.error,
            content: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onError,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final userProvider = context.watch<AdminUserProvider>();
    final colorScheme = Theme.of(context).colorScheme;

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
                        CreateTaskHeader(
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 28),

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.7),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha:
                                      colorScheme.brightness == Brightness.dark
                                      ? 0.10
                                      : 0.025,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const EditTaskSectionLabel(
                                icon: Icons.edit_note_rounded,
                                title: 'Task information',
                                subtitle: 'Define what needs to be done.',
                              ),
                              const SizedBox(height: 20),
                              TaskInformationCard(
                                titleController: _titleController,
                                descriptionController: _descriptionController,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const EditTaskSectionLabel(
                                icon: Icons.tune_rounded,
                                title: 'Task settings',
                                subtitle: 'Set priority and assignment.',
                              ),
                              const SizedBox(height: 20),
                              TaskPrioritySelector(
                                selectedPriority: _selectedPriority,
                                onChanged: (priority) {
                                  setState(() {
                                    _selectedPriority = priority;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              CreateTaskAssignmentSection(
                                provider: userProvider,
                                selectedUserId: _selectedUserId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Keep your task title clear and specific so the assigned user knows exactly what needs to be done.',
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        CreateTaskButton(
                          isLoading: taskProvider.isActionLoading,
                          onPressed: _createTask,
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Your task data is securely stored.',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
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
}
