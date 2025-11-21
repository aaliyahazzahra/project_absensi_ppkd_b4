import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class AuthBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AuthBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: AppColor.retroDarkRed),
            const SizedBox(width: 8),
            Text(
              'Back',
              style: TextStyle(
                color: AppColor.retroDarkRed,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
