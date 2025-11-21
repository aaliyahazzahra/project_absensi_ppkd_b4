import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColor.retroDarkRed,
        foregroundColor: textColor ?? AppColor.retroCream,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.grey[400],
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? AppColor.retroCream,
                ),
                strokeWidth: 3,
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
    );
  }
}
