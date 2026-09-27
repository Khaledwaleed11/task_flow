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

class _EditProjectScreenState extends State<EditProjectScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.project.name);

    _descriptionController = TextEditingController(
      text: widget.project.description,
    );

    _descriptionController.addListener(_onDescriptionChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

    _animationController.dispose();

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
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update project'),
          backgroundColor: AppColors.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, provider, child) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EditProjectTopBar(
                              onBack: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(height: 30),
                            const ProjectFormHeader(
                              title: 'Edit Project',
                              subtitle: 'Update your project information and keep it organized.',
                              icon: Icons.edit_rounded,
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(22),
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit_note_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Project information',
                                              style: AppTextStyles.title,
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              'Update the details of your project.',
                                              style:
                                                  AppTextStyles.bodySecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  ProjectInformationCard(
                                    nameController: _nameController,
                                    descriptionController:
                                        _descriptionController,
                                    nameLabel: 'Project Name',
                                    nameHint: 'Enter your project name',
                                    descriptionLabel: 'Description',
                                    descriptionHint:
                                        'Describe what this project is about',
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
                                  const SizedBox(height: 22),
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
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Changes will be saved to your workspace.',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11,
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
            );
          },
        ),
      ),
    );
  }
}

class _EditProjectTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _EditProjectTopBar({required this.onBack});

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
        Text('Edit Project', style: AppTextStyles.title.copyWith(fontSize: 17)),
      ],
    );
  }
}
