import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/utils/home_helper.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/today_status_response.dart';

class HomeHeaderSection extends StatelessWidget {
  final String userName;
  final TodayStatusData? todayStatus;
  final bool isLoading;

  const HomeHeaderSection({
    super.key,
    required this.userName,
    required this.todayStatus,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final statusEnum = HomeHelper.getTodayStatus(todayStatus);
    final style = HomeHelper.getStatusStyle(statusEnum);
    final bgImage = HomeHelper.getHeaderBackgroundImage();

    // Format jam shift dari Helper
    String startH = HomeHelper.shiftStartHour.toString().padLeft(2, '0');
    String startM = HomeHelper.shiftStartMinute.toString().padLeft(2, '0');
    String endH = HomeHelper.shiftEndHour.toString().padLeft(2, '0');
    final String workShift = "Regular Shift ($startH:$startM - $endH:00)";

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                HomeHelper.getGreeting(),
                style: TextStyle(
                  color: AppColor.retroCream.withOpacity(0.9),
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              const Spacer(),
              isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColor.retroCream,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.check_circle,
                      color: AppColor.retroCream,
                      size: 28,
                    ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: TextStyle(
              color: AppColor.retroCream,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 10, color: Colors.black)],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColor.retroLightRed.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColor.retroCream.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Status",
                      style: TextStyle(
                        color: AppColor.retroCream,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: style['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            style['icon'],
                            size: 14,
                            color: style['textColor'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            style['text'],
                            style: TextStyle(
                              color: style['textColor'],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeCol(
                      "Check-In",
                      isLoading ? "..." : (todayStatus?.checkInTime ?? "--:--"),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColor.retroCream.withOpacity(0.5),
                    ),
                    _buildTimeCol(
                      "Check-Out",
                      isLoading
                          ? "..."
                          : (todayStatus?.checkOutTime ?? "--:--"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: AppColor.retroCream.withOpacity(0.3)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: AppColor.retroCream,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      workShift,
                      style: TextStyle(
                        color: AppColor.retroCream,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCol(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColor.retroCream.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: AppColor.retroCream,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
