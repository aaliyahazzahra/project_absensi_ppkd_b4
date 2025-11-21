import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class AuthFooter extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onActionTap;

  const AuthFooter({
    super.key,
    required this.text,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: AppColor.retroDarkRed.withOpacity(0.7)),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColor.retroLightRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
