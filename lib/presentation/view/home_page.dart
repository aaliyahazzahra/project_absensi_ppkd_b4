import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isInitialLoading = true;
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    final provider = context.read<AttendanceProvider>();

    if (mounted) {
      setState(() {
        _isInitialLoading = true;
      });
    }

    try {
      await context.read<ProfileProvider>().fetchProfileData();
      await provider.fetchTodayStatusData();
      _fetchWeeklyStats(provider);
    } catch (e) {
      debugPrint('Error fetching initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _dataFetched = true;
        });
      }
    }
  }

  void _fetchWeeklyStats(AttendanceProvider provider) {
    final now = DateTime.now();
    DateTime endDate = now;
    DateTime startDate = now.subtract(const Duration(days: 6));

    final formatter = DateFormat('yyyy-MM-dd');

    provider.fetchAttendanceStats(
      startDate: formatter.format(startDate),
      endDate: formatter.format(endDate),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Good Morning,';
    } else if (hour < 15) {
      return 'Good Afternoon,';
    } else if (hour < 18) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.retroDarkRed),
      );
    }

    final profileProvider = context.watch<ProfileProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    final stats = attendanceProvider.statsData;
    final totalMasuk = stats?.totalMasuk ?? 0;
    final totalIzin = stats?.totalIzin ?? 0;
    final totalAbsen = stats?.totalAbsen ?? 0;

    final String todayWorkingHours = attendanceProvider.totalWorkingHoursToday;

    final String weeklyStatsSubValue = attendanceProvider.isLoadingStats
        ? "Loading weekly statistics..."
        : "Statistics from ${DateFormat('dd MMM').format(DateTime.now().subtract(const Duration(days: 6)))} - ${DateFormat('dd MMM').format(DateTime.now())}";

    String userName = profileProvider.isLoading
        ? "Loading..."
        : (profileProvider.userProfile?.name ?? "User");

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
              title: "Total Working Hours Today", // Diterjemahkan
              icon: Icons.timer_outlined,
              mainValue: attendanceProvider.isLoadingStatus
                  ? "..."
                  : todayWorkingHours,
              subValue: "Recorded working duration today.", // Diterjemahkan
            ),
            const SizedBox(height: 24),

            _buildInfoCard(
              title: "Weekly Attendance Statistics", // Diterjemahkan
              icon: Icons.bar_chart_outlined,
              child: attendanceProvider.isLoadingStats
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: CircularProgressIndicator(
                          color: AppColor.retroMediumRed,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildStatRow(
                          "Total Days Attended", // Diterjemahkan
                          totalMasuk.toString(),
                          Colors.green,
                        ),
                        _buildStatRow(
                          "Total Days Permitted Leave", // Diterjemahkan
                          totalIzin.toString(),
                          Colors.amber,
                        ),
                        _buildStatRow(
                          "Total Days Absent", // Diterjemahkan
                          totalAbsen.toString(),
                          AppColor.retroDarkRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          weeklyStatsSubValue,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColor.retroMediumRed),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColor.retroDarkRed.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    String userName,
    String checkInTime,
    String checkOutTime,
    bool isLoading,
  ) {
    final String greeting = _getGreeting();
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
            greeting,
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
    final attendanceProvider = context.watch<AttendanceProvider>();
    final todayStatus = attendanceProvider.todayStatus;

    final bool isCheckingIn = attendanceProvider.isCheckingIn;
    final bool isCheckingOut = attendanceProvider.isCheckingOut;

    final bool hasCheckedIn = todayStatus?.checkInTime != null;
    final bool hasCheckedOut = todayStatus?.checkOutTime != null;

    final bool isCheckInEnabled =
        !hasCheckedIn && !isCheckingIn && !isCheckingOut;
    final bool isCheckOutEnabled =
        hasCheckedIn && !hasCheckedOut && !isCheckingIn && !isCheckingOut;

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: isCheckingIn ? "Loading..." : "Check In",
            icon: isCheckingIn ? Icons.hourglass_empty : Icons.login,
            isPrimary: true,
            isDisabled: !isCheckInEnabled,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckInPage()),
              );
              _fetchInitialData();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            label: isCheckingOut ? "Loading..." : "Check Out",
            icon: isCheckingOut ? Icons.hourglass_empty : Icons.logout,
            isPrimary: false,
            isDisabled: !isCheckOutEnabled,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckOutPage()),
              );
              _fetchInitialData();
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
    required VoidCallback? onPressed,
    required bool isDisabled,
  }) {
    return SizedBox(
      height: 120,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey[400]
              : isPrimary
              ? AppColor.retroDarkRed
              : AppColor.kBackgroundColor,
          foregroundColor: isDisabled
              ? Colors.grey[600]
              : isPrimary
              ? AppColor.retroCream
              : AppColor.retroDarkRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: (isPrimary || isDisabled)
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
