import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value; // Nilai yang sedang terpilih
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isExpanded;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isExpanded = true,
  });

  TextStyle _hintStyle() {
    return TextStyle(color: AppColor.retroMediumRed.withOpacity(0.6));
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColor.retroCream.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.retroDarkRed,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),

        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: isExpanded,
          hint: Text(hintText, style: _hintStyle()),
          decoration: _buildInputDecoration(),
          items: items,
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
