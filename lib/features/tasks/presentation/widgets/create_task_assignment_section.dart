import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/presentation/providers/admin_user_provider.dart';

class CreateTaskAssignmentSection extends StatelessWidget {
  final AdminUserProvider provider;
  final String? selectedUserId;
  final ValueChanged<String?> onChanged;

  const CreateTaskAssignmentSection({
    super.key,
    required this.provider,
    required this.selectedUserId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          initialValue: selectedUserId,
          decoration: const InputDecoration(
            labelText: 'Assign to',
            hintText: 'Select a user',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No assignment'),
            ),
            ...provider.assignableUsers.map((user) {
              return DropdownMenuItem<String?>(
                value: user.id,
                child: Text(user.email, overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: provider.hasAssignableUsers ? onChanged : null,
        ),

        if (provider.status == AdminUserStatus.loading) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            minHeight: 2,
            color: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
          ),
        ],

        if (!provider.hasAssignableUsers &&
            provider.status == AdminUserStatus.loaded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No users are currently available for assignment.',
                    style: AppTextStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
