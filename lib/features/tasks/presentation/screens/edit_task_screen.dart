import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/edit_task_header.dart';
import '../widgets/edit_task_information_card.dart';
import '../widgets/edit_task_priority_selector.dart';
import '../widgets/save_task_button.dart';
import '../widgets/task_completion_switch.dart';

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

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late TaskPriority _selectedPriority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);

    _descriptionController = TextEditingController(
      text: widget.task.description,
    );

    _selectedPriority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;

    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();

    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();

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
      isCompleted: _isCompleted,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      return;
    }

    final message = provider.actionErrorMessage ?? 'Failed to update task';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditTaskHeader(),

                const SizedBox(height: 28),

                EditTaskInformationCard(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),

                const SizedBox(height: 24),

                EditTaskPrioritySelector(
                  selectedPriority: _selectedPriority,
                  onChanged: (priority) {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                ),

                const SizedBox(height: 24),

                TaskCompletionSwitch(
                  isCompleted: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                SaveTaskButton(
                  isLoading: provider.isActionLoading,
                  onPressed: _updateTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
