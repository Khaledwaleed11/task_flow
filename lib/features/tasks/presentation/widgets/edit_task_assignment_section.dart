import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/presentation/providers/admin_user_provider.dart';

class EditTaskAssignmentSection extends StatelessWidget {
  final AdminUserProvider provider;
  final String? selectedUserId;
  final ValueChanged<String?> onChanged;

  const EditTaskAssignmentSection({
    super.key,
    required this.provider,
    required this.selectedUserId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final usersById = <String, dynamic>{};

    for (final user in provider.assignableUsers) {
      usersById[user.id] = user;
    }

    final users = usersById.values.toList();

    final hasSelectedUser =
        selectedUserId != null &&
        users.any((user) => user.id == selectedUserId);

    final dropdownValue = hasSelectedUser ? selectedUserId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignment',
          style: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          initialValue: dropdownValue,
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
            ...users.map((user) {
              return DropdownMenuItem<String?>(
                value: user.id,
                child: Text(user.email, overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: users.isNotEmpty ? onChanged : null,
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
