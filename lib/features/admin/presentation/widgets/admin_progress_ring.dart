import 'package:flutter/material.dart';

class AdminProgressRing extends StatelessWidget {
  final int percentage;

  const AdminProgressRing({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final safePercentage = percentage.clamp(0, 100);

    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: CircularProgressIndicator(
              value: safePercentage / 100,
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(
                alpha: 0.14,
              ),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$safePercentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'done',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.65,
                  ),
                  fontSize: 9,
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