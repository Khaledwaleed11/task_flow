import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: Theme.of(context).brightness ==
                Brightness.dark
                ? 0.3
                : 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Information',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color,
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            validator: nameValidator,
            decoration: InputDecoration(
              labelText: nameLabel,
              hintText: nameHint,
              prefixIcon: const Icon(
                Icons.folder_outlined,
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: descriptionController,
            textInputAction: TextInputAction.newline,
            validator: descriptionValidator,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: descriptionLabel,
              hintText: descriptionHint,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  bottom: 72,
                ),
                child: Icon(
                  Icons.description_outlined,
                ),
              ),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}