import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/attendance_stats_response.dart';

// Import widget row yang baru kita buat
import 'home_stat_row.dart';

class HomeWeeklyStatsCard extends StatelessWidget {
  final bool isLoading;
  final AttendanceStatsData? stats;

  const HomeWeeklyStatsCard({
    super.key,
    required this.isLoading,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final totalMasuk = stats?.totalMasuk ?? 0;
    final totalIzin = stats?.totalIzin ?? 0;
    final totalAbsen = stats?.totalAbsen ?? 0;

    final String subValue = isLoading
        ? "Loading weekly statistics..."
        : "Statistics from ${DateFormat('dd MMM').format(DateTime.now().subtract(const Duration(days: 6)))} - ${DateFormat('dd MMM').format(DateTime.now())}";

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
                "Weekly Attendance Statistics",
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.bar_chart_outlined, color: AppColor.retroMediumRed),
            ],
          ),
          Divider(color: AppColor.retroMediumRed.withOpacity(0.4), height: 24),
          isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(
                      color: AppColor.retroMediumRed,
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    // Panggil Widget Row yang sudah dipecah
                    HomeStatRow(
                      label: "Days Present",
                      value: totalMasuk.toString(),
                      color: Colors.green,
                      icon: Icons.check_circle_outline,
                    ),
                    HomeStatRow(
                      label: "Leave / Sick",
                      value: totalIzin.toString(),
                      color: Colors.orange,
                      icon: Icons.assignment_ind_outlined,
                    ),
                    HomeStatRow(
                      label: "Absent",
                      value: totalAbsen.toString(),
                      color: AppColor.retroDarkRed,
                      icon: Icons.cancel_outlined,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppColor.retroMediumRed.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    Text(
                      subValue,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.retroMediumRed,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
