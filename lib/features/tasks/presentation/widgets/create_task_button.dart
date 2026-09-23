import 'package:flutter/material.dart';

class CreateTaskButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CreateTaskButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 200,
          ),
          child: isLoading
              ? const Row(
            key: ValueKey('loading'),
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Creating...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : const Row(
            key: ValueKey('button'),
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_task_rounded,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Create Task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}