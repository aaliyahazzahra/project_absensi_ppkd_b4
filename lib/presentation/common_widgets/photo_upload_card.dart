import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_card.dart';

class PhotoUploadCard extends StatelessWidget {
  const PhotoUploadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: AppColor.retroDarkRed),
              const SizedBox(width: 8),
              Text(
                'Photo Verification',
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColor.retroCream.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_enhance_outlined,
                    size: 40,
                    color: AppColor.retroMediumRed,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to capture photo',
                    style: TextStyle(
                      color: AppColor.retroMediumRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
