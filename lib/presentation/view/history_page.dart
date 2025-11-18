import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';

enum AttendanceStatus { present, absent, late, weekend }

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk UI
    final List<Map<String, dynamic>> historyData = [
      {
        "day": "Mon",
        "date": "15",
        "checkIn": "08:30 AM",
        "checkOut": "05:15 PM",
        "status": AttendanceStatus.present,
      },
      {
        "day": "Sun",
        "date": "14",
        "checkIn": "--",
        "checkOut": "--",
        "status": AttendanceStatus.weekend,
      },
      {
        "day": "Sat",
        "date": "13",
        "checkIn": "--",
        "checkOut": "--",
        "status": AttendanceStatus.weekend,
      },
      {
        "day": "Fri",
        "date": "12",
        "checkIn": "08:25 AM",
        "checkOut": "05:10 PM",
        "status": AttendanceStatus.present,
      },
      {
        "day": "Thu",
        "date": "11",
        "checkIn": "08:35 AM",
        "checkOut": "05:20 PM",
        "status": AttendanceStatus.present,
      },
      {
        "day": "Wed",
        "date": "10",
        "checkIn": "09:15 AM",
        "checkOut": "05:05 PM",
        "status": AttendanceStatus.late,
      },
      {
        "day": "Tue",
        "date": "09",
        "checkIn": "08:30 AM",
        "checkOut": "05:15 PM",
        "status": AttendanceStatus.present,
      },
      {
        "day": "Mon",
        "date": "08",
        "checkIn": "--",
        "checkOut": "--",
        "status": AttendanceStatus.absent,
      },
    ];

    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return _buildHistoryItem(
                  day: item["day"],
                  date: item["date"],
                  checkIn: item["checkIn"],
                  checkOut: item["checkOut"],
                  status: item["status"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Text(
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
                Icon(Icons.chevron_left, color: AppColor.retroCream),
                Text(
                  'November 2025',
                  style: TextStyle(
                    color: AppColor.retroCream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColor.retroCream),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String day,
    required String date,
    required String checkIn,
    required String checkOut,
    required AttendanceStatus status,
  }) {
    final statusStyle = _getStatusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColor.kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.retroMediumRed.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColor.retroMediumRed.withOpacity(0.1),
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
              color: AppColor.retroMediumRed,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: AppColor.retroCream,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
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
                    _buildTimeColumn("Check-In", checkIn),
                    _buildTimeColumn("Check-Out", checkOut),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  statusStyle['text']!,
                  style: TextStyle(
                    color: statusStyle['color'],
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

  // Helper untuk kolom Check-In / Check-Out
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

  // Helper untuk mendapatkan teks dan warna status
  Map<String, dynamic> _getStatusStyle(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return {'text': 'Present', 'color': Colors.green[700]};
      case AttendanceStatus.absent:
        return {'text': 'Absent', 'color': AppColor.retroMediumRed};
      case AttendanceStatus.late:
        return {'text': 'Late', 'color': Colors.orange[800]};
      case AttendanceStatus.weekend:
        return {'text': 'Weekend', 'color': AppColor.retroLightRed};
    }
  }
}
