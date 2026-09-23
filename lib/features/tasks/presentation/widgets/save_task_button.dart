import 'package:flutter/material.dart';

class SaveTaskButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SaveTaskButton({
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
        onPressed:
        isLoading ? null : onPressed,
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
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Saving...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          )
              : const Row(
            key: ValueKey('save'),
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.save_rounded,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}