import 'package:flutter/material.dart';

class AdminUserInitial extends StatelessWidget {
  final String initial;
  final Color roleColor;

  const AdminUserInitial({
    super.key,
    required this.initial,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: roleColor,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}