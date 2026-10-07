import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class EditTaskInformationCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const EditTaskInformationCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task information',
            style: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Task title',
              hintText: 'Enter task title',
              prefixIcon: Icon(Icons.title_rounded),
            ),
            validator: (value) {
              final title = value?.trim() ?? '';

              if (title.isEmpty) {
                return 'Please enter a task title.';
              }

              if (title.length < 3) {
                return 'Task title must be at least 3 characters.';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: descriptionController,
            maxLines: 5,
            minLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter task description',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 72),
                child: Icon(Icons.description_outlined),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Keep the description clear and actionable.',
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${descriptionController.text.length}/500',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
