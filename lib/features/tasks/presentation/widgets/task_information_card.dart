import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withValues(
            alpha: 0.10,
          )
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.10 : 0.04,
            ),
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
            style: AppTextStyles.title.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Task title',
              hintText: 'e.g. Build login screen',
              prefixIcon: Icon(
                Icons.task_alt_outlined,
              ),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter a task title.';
              }

              if (value.trim().length < 3) {
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
              hintText: 'Describe what needs to be done...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  bottom: 72,
                ),
                child: Icon(
                  Icons.description_outlined,
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
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Keep the task description clear and actionable.',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${descriptionController.text.length}/500',
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}