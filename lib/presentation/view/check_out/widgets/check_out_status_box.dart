import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';

class CheckOutStatusBox extends StatelessWidget {
  const CheckOutStatusBox({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final String clockInTime =
        attendanceProvider.todayStatus?.checkInTime ?? "--:--";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[700]!, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'You are currently clocked in',
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Started at $clockInTime',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
