import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class HistoryHeaderSection extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;

  const HistoryHeaderSection({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const Text(
            'Attendance History',
            style: TextStyle(
              color: AppColor.retroCream,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.retroMediumRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onPreviousMonth,
                  child: Icon(Icons.chevron_left, color: AppColor.retroCream),
                ),
                GestureDetector(
                  onTap: onSelectMonth,
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(currentMonth),
                        style: TextStyle(
                          color: AppColor.retroCream,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        color: AppColor.retroCream,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onNextMonth,
                  child: Icon(Icons.chevron_right, color: AppColor.retroCream),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
