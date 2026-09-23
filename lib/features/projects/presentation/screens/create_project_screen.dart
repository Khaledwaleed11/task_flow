import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/project_provider.dart';
import '../widgets/project_form_header.dart';
import '../widgets/project_information_card.dart';
import '../widgets/project_submit_button.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController
      ..removeListener(_onDescriptionChanged)
      ..dispose();

    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter a project name.';
    }

    if (name.length < 3) {
      return 'Project name must be at least 3 characters.';
    }

    return null;
  }

  Future<void> _createProject() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ProjectProvider>();

    final success = await provider.createProject(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Project created successfully'),
            backgroundColor: AppColors.success,
          ),
        );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create project'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, provider, child) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    const ProjectFormHeader(
                      title: 'Create Project',
                      subtitle: 'Create a new project and start organizing your tasks.',
                      icon: Icons.create_new_folder_rounded,
                    ),

                    const SizedBox(height: 28),

                    ProjectInformationCard(
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      nameLabel: 'Project Name',
                      nameHint: 'Enter your project name',
                      descriptionLabel: 'Description',
                      descriptionHint: 'Describe what this project is about',
                      nameValidator: _validateName,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_descriptionController.text.length}/500',
                        style: AppTextStyles.caption,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ProjectSubmitButton(
                      isLoading: provider.isLoading,
                      label: 'Create Project',
                      loadingLabel: 'Creating...',
                      icon: Icons.add_rounded,
                      onPressed: _createProject,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
