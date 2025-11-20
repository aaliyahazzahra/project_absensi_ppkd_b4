import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/enums/attendance_status.dart';
import 'package:project_absensi_ppkd_b4/core/utils/history_helper.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/history_response.dart';

class HistoryCardItem extends StatelessWidget {
  final HistoryData item;

  const HistoryCardItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final DateTime date = item.attendanceDate;
    final String dayOfWeek = DateFormat('E').format(date);
    final String dayOfMonth = DateFormat('dd').format(date);

    // Gunakan Helper untuk logic
    final String checkInTime = HistoryHelper.formatTime(item.checkInTime, date);
    final String checkOutTime = HistoryHelper.formatTime(
      item.checkOutTime,
      date,
    );
    final AttendanceStatus status = HistoryHelper.getStatusFromApi(item);
    final Map<String, dynamic> statusStyle = HistoryHelper.getStatusStyle(
      status,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColor.kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusStyle['borderColor'] as Color),
        boxShadow: [
          BoxShadow(
            color: statusStyle['shadowColor'] as Color,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusStyle['color'] as Color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayOfWeek,
                  style: TextStyle(
                    color: AppColor.retroCream,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dayOfMonth,
                  style: TextStyle(
                    color: AppColor.retroCream,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn("Check-In", checkInTime),
                    _buildTimeColumn("Check-Out", checkOutTime),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  statusStyle['text']!,
                  style: TextStyle(
                    color: statusStyle['textColor'],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColor.retroMediumRed.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: AppColor.retroDarkRed,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
