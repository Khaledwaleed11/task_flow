import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class TaskDueDateSelector extends StatelessWidget {
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onChanged;

  const TaskDueDateSelector({
    super.key,
    required this.dueDate,
    required this.onChanged,
  });

  TimeOfDay get _initialTime {
    if (dueDate != null) {
      return TimeOfDay.fromDateTime(dueDate!);
    }

    return const TimeOfDay(hour: 17, minute: 0);
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );

    if (pickedDate == null || !context.mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );

    if (pickedTime == null || !context.mounted) {
      return;
    }

    onChanged(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due date',
          style: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          'Optional deadline. You will be reminded 2 hours before it and again on the day.',
          style: AppTextStyles.bodySecondary.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (dueDate == null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickDueDate(context),
              icon: const Icon(Icons.event_rounded),
              label: const Text('Set due date'),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${MaterialLocalizations.of(context).formatMediumDate(dueDate!)}'
                    ' • ${MaterialLocalizations.of(context).formatTimeOfDay(_initialTime)}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear due date',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onChanged(null),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                IconButton(
                  tooltip: 'Change due date',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _pickDueDate(context),
                  icon: Icon(
                    Icons.edit_calendar_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
