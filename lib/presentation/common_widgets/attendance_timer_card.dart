import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_card.dart';

class AttendanceTimerCard extends StatelessWidget {
  final String date;
  final String time;

  const AttendanceTimerCard({
    super.key,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            date,
            style: TextStyle(
              color: AppColor.retroDarkRed,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(color: AppColor.retroMediumRed.withOpacity(0.4), height: 32),
          Text(
            time,
            style: TextStyle(
              color: AppColor.retroMediumRed,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
