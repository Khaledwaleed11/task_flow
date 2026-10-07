import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _CreateProjectScreenState extends State<CreateProjectScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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

    final colorScheme = Theme.of(context).colorScheme;

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Project created successfully'),
            backgroundColor: colorScheme.tertiary,
          ),
        );

      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create project'),
          backgroundColor: colorScheme.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                            _CreateProjectTopBar(
                              onBack: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(height: 30),
                            const ProjectFormHeader(
                              title: 'Create Project',
                              subtitle: 'Create a new project and start organizing your tasks.',
                              icon: Icons.create_new_folder_rounded,
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: isDark ? 0.55 : 0.7,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.10 : 0.025,
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
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.folder_outlined,
                                          color: colorScheme.primary,
                                          size: 21,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Project information',
                                              style: AppTextStyles.title
                                                  .copyWith(
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Add the basic details for your workspace.',
                                              style: AppTextStyles.bodySecondary
                                                  .copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
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
                                      style: AppTextStyles.caption.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
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
                            const SizedBox(height: 18),
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
                                  'Your project data is securely stored.',
                                  style: AppTextStyles.caption.copyWith(
                                    color: colorScheme.onSurfaceVariant,
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

class _CreateProjectTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _CreateProjectTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            fixedSize: const Size(44, 44),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.7)),
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'New Project',
          style: AppTextStyles.title.copyWith(
            fontSize: 17,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
