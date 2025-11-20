import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  final bool readOnly;
  final Color? fillColor;
  final Color? labelColor;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.readOnly = false,
    this.fillColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color finalLabelColor = readOnly
        ? labelColor ?? Colors.grey[700]!
        : AppColor.retroDarkRed;

    final Color finalFillColor = readOnly
        ? fillColor ?? Colors.grey[200]!
        : AppColor.retroCream.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: finalLabelColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),

        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColor.retroMediumRed.withOpacity(0.6),
            ),
            filled: true,
            fillColor: finalFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            color: readOnly ? Colors.grey[600] : AppColor.retroDarkRed,
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
