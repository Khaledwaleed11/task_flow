import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ProjectInformationCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String nameLabel;
  final String nameHint;
  final String descriptionLabel;
  final String descriptionHint;
  final String? Function(String?)? nameValidator;
  final String? Function(String?)? descriptionValidator;

  const ProjectInformationCard({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.nameLabel,
    required this.nameHint,
    required this.descriptionLabel,
    required this.descriptionHint,
    this.nameValidator,
    this.descriptionValidator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          nameLabel,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          validator: nameValidator,
          decoration: InputDecoration(
            hintText: nameHint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(9),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.folder_outlined,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          descriptionLabel,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: descriptionController,
          textInputAction: TextInputAction.newline,
          validator: descriptionValidator,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: descriptionHint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 13,
                right: 13,
                bottom: 72,
                top: 13,
              ),
              child: Icon(
                Icons.description_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            alignLabelWithHint: true,
            counterText: '',
          ),
        ),
      ],
    );
  }
}