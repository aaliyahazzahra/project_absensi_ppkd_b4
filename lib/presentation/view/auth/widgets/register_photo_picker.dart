import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class RegisterPhotoPicker extends StatelessWidget {
  final String photoName;
  final bool hasImage;
  final VoidCallback onTap;

  const RegisterPhotoPicker({
    super.key,
    required this.photoName,
    required this.hasImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photo (Optional)',
          style: TextStyle(
            color: AppColor.retroDarkRed,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: AppColor.retroCream.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            leading: Icon(Icons.photo_outlined, color: AppColor.retroDarkRed),
            title: Text(
              photoName,
              style: TextStyle(
                color: hasImage
                    ? AppColor.retroDarkRed
                    : AppColor.retroMediumRed.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
