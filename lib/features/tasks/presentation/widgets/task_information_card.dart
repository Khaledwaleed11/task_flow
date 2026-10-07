import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class TaskInformationCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const TaskInformationCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Task title',
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'e.g. Build login screen',
            prefixIcon: Container(
              margin: const EdgeInsets.all(9),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.task_alt_outlined,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a task title.';
            }

            if (value.trim().length < 3) {
              return 'Task title must be at least 3 characters.';
            }

            return null;
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Description',
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: descriptionController,
          maxLines: 5,
          minLines: 4,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Describe what needs to be done...',
            alignLabelWithHint: true,
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
                'Keep the task description clear and actionable.',
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
    );
  }
}
