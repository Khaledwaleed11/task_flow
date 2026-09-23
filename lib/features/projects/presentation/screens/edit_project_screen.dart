import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/project_provider.dart';
import '../widgets/project_form_header.dart';
import '../widgets/project_information_card.dart';
import '../widgets/project_submit_button.dart';

class EditProjectScreen extends StatefulWidget {
  final ProjectEntity project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.project.name);

    _descriptionController = TextEditingController(
      text: widget.project.description,
    );

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

  Future<void> _updateProject() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ProjectProvider>();

    final success = await provider.updateProject(
      projectId: widget.project.id,
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
            content: Text('Project updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update project'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
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
                      title: 'Edit Project',
                      subtitle: 'Update your project information and keep it organized.',
                      icon: Icons.edit_rounded,
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
                      label: 'Save Changes',
                      loadingLabel: 'Saving...',
                      icon: Icons.save_rounded,
                      onPressed: _updateProject,
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
