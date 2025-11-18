import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/check_in_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/check_out_page.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
      context.read<AttendanceProvider>().fetchTodayStatusData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    String userName = profileProvider.isLoading
        ? "Memuat..."
        : (profileProvider.userProfile?.name ?? "Pengguna");

    String checkInTime = attendanceProvider.isLoadingStatus
        ? "..."
        : (attendanceProvider.todayStatus?.checkInTime ?? "--:--");

    String checkOutTime = attendanceProvider.isLoadingStatus
        ? "..."
        : (attendanceProvider.todayStatus?.checkOutTime ?? "--:--");

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(
              userName,
              checkInTime,
              checkOutTime,
              attendanceProvider.isLoadingStatus,
            ),
            const SizedBox(height: 24),

            _buildActionButtons(context),
            const SizedBox(height: 24),

            _buildInfoCard(
              title: "Total Working Hours",
              icon: Icons.timer_outlined,
              mainValue: "0h 0m",
              subValue: "This Week: 32h 15m",
            ),
            const SizedBox(height: 24),

            _buildInfoCard(
              title: "Weekly Overview",
              icon: Icons.more_horiz_outlined,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'Weekly chart will be here',
                    style: TextStyle(color: AppColor.retroMediumRed),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    String userName,
    String checkInTime,
    String checkOutTime,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning,',
            style: TextStyle(
              color: AppColor.retroCream.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          Text(
            userName,
            style: TextStyle(
              color: AppColor.retroCream,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColor.retroLightRed,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Today's Status",
                  style: TextStyle(
                    color: AppColor.retroCream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusColumn("Check-In", checkInTime),
                    _buildStatusColumn("Check-Out", checkOutTime),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: isLoading
                      ? SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            color: AppColor.retroCream.withOpacity(0.7),
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          Icons.check_circle_outline,
                          color: AppColor.retroCream.withOpacity(0.7),
                          size: 28,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColumn(String title, String time) {
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: "Clock In",
            icon: Icons.login,
            isPrimary: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckInPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            label: "Clock Out",
            icon: Icons.logout,
            isPrimary: false,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckOutPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 120,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColor.retroDarkRed
              : AppColor.kBackgroundColor,
          foregroundColor: isPrimary
              ? AppColor.retroCream
              : AppColor.retroDarkRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: AppColor.retroDarkRed, width: 2),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    String? mainValue,
    String? subValue,
    Widget? child,
  }) {
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
            offset: Offset(0, 5),
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
                title,
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: AppColor.retroMediumRed),
            ],
          ),
          Divider(color: AppColor.retroMediumRed.withOpacity(0.4), height: 24),
          child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    mainValue ?? "",
                    style: TextStyle(
                      color: AppColor.retroDarkRed,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subValue ?? "",
                    style: TextStyle(
                      color: AppColor.retroMediumRed,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
