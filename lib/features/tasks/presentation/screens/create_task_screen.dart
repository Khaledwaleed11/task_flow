import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/create_task_button.dart';
import '../widgets/create_task_header.dart';
import '../widgets/task_information_card.dart';
import '../widgets/task_priority_selector.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;

  const CreateTaskScreen({super.key, required this.projectId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CreateTaskHeader(),

                const SizedBox(height: 28),

                TaskInformationCard(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),

                const SizedBox(height: 24),

                TaskPrioritySelector(
                  selectedPriority: _selectedPriority,
                  onChanged: (priority) {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                ),

                const SizedBox(height: 28),

                CreateTaskButton(
                  isLoading: provider.isActionLoading,
                  onPressed: _createTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
