import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class HomeWorkingHoursCard extends StatelessWidget {
  final String workingHours;
  final bool isLoading;

  const HomeWorkingHoursCard({
    super.key,
    required this.workingHours,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColor.kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.retroMediumRed.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColor.retroMediumRed.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Working Hours Today",
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.timer_outlined, color: AppColor.retroMediumRed),
            ],
          ),
          Divider(color: AppColor.retroMediumRed.withOpacity(0.4), height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                isLoading ? "..." : workingHours,
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Recorded working duration today.",
                style: TextStyle(color: AppColor.retroMediumRed, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
