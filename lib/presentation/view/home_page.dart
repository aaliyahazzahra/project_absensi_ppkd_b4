import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/models/response/today_status_response.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/check_in/check_in_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/check_out/check_out_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/history_page.dart';
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
  // bool _dataFetched = false;
  final int _shiftStartHour = 8;
  final int _shiftStartMinute = 0;
  final int _shiftEndHour = 17;

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
          // _dataFetched = true;
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

  String _getHeaderBackgroundImage() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'assets/images/morning_banner.png';
    } else if (hour < 15) {
      return 'assets/images/afternoon_banner.png';
    } else if (hour < 18) {
      return 'assets/images/evening_banner.png';
    } else {
      return 'assets/images/night_banner.png';
    }
  }

  AttendanceStatus _getTodayStatus(TodayStatusData? data) {
    if (data == null) {
      return AttendanceStatus.incomplete;
    }

    final status = data.status?.toLowerCase() ?? '';
    final checkIn = data.checkInTime;
    final checkOut = data.checkOutTime;

    if (status.contains('izin') || status.contains('sakit')) {
      return AttendanceStatus.izin;
    }

    if (status.contains('weekend') || status.contains('libur')) {
      return AttendanceStatus.weekend;
    }

    if (status.contains('late') || status.contains('terlambat')) {
      return AttendanceStatus.late;
    }

    if (checkIn != null) {
      try {
        final now = DateTime.now();
        final timeParts = checkIn.split(':');
        final checkInDate = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        final shiftStart = DateTime(
          now.year,
          now.month,
          now.day,
          _shiftStartHour,
          _shiftStartMinute,
        );
        if (checkInDate.isAfter(shiftStart) && !status.contains('late')) {
          return AttendanceStatus.late;
        }
      } catch (_) {}
    }

    if (checkIn != null && checkOut == null) {
      return AttendanceStatus.incomplete;
    }

    if (checkIn != null && checkOut != null) {
      return AttendanceStatus.present;
    }

    return AttendanceStatus.absent;
  }

  Map<String, dynamic> _getStatusStyle(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return {
          'text': 'On Time - Present',
          'color': Colors.green[100],
          'textColor': Colors.green[800],
          'icon': Icons.check_circle,
        };
      case AttendanceStatus.late:
        return {
          'text': 'Late Arrival',
          'color': Colors.orange[100],
          'textColor': Colors.orange[800],
          'icon': Icons.warning_amber_rounded,
        };
      case AttendanceStatus.izin:
        return {
          'text': 'On Leave / Sick',
          'color': Colors.blue[100],
          'textColor': Colors.blue[800],
          'icon': Icons.assignment_ind,
        };
      case AttendanceStatus.incomplete:
        return {
          'text':
              'Currently Working', // Beda dikit bahasanya biar enak dilihat di Home
          'color': Colors.blueGrey[100],
          'textColor': Colors.blueGrey[800],
          'icon': Icons.work_history,
        };
      case AttendanceStatus.weekend:
        return {
          'text': 'Holiday / Weekend',
          'color': AppColor.retroLightRed,
          'textColor': AppColor.retroMediumRed,
          'icon': Icons.calendar_month,
        };
      default:
        return {
          'text': 'Not Checked In Yet',
          'color': Colors.grey[200],
          'textColor': Colors.grey[600],
          'icon': Icons.hourglass_empty,
        };
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
              title: "Total Working Hours Today",
              icon: Icons.timer_outlined,
              mainValue: attendanceProvider.isLoadingStatus
                  ? "..."
                  : todayWorkingHours,
              subValue: "Recorded working duration today.",
            ),
            const SizedBox(height: 24),

            _buildInfoCard(
              title: "Weekly Attendance Statistics",
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
                          label: "Days Present",
                          value: totalMasuk.toString(),
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                        _buildStatRow(
                          label: "Leave / Sick",
                          value: totalIzin.toString(),
                          color: Colors.orange,
                          icon: Icons.assignment_ind_outlined,
                        ),
                        _buildStatRow(
                          label: "Absent",
                          value: totalAbsen.toString(),
                          color: AppColor.retroDarkRed,
                          icon: Icons.cancel_outlined,
                        ),
                        const SizedBox(height: 16),

                        Divider(
                          color: AppColor.retroMediumRed.withOpacity(0.2),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          weeklyStatsSubValue,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.retroMediumRed,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColor.retroCream.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.retroMediumRed.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColor.retroDarkRed.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceVerdict(String? checkInTimeStr) {
    if (checkInTimeStr == null || checkInTimeStr == "--:--") {
      return Text("Not Present Yet", style: TextStyle(color: Colors.grey));
    }

    try {
      final now = DateTime.now();
      final format = DateFormat("HH:mm");
      final checkInTime = format.parse(checkInTimeStr);

      final fullCheckInDate = DateTime(
        now.year,
        now.month,
        now.day,
        checkInTime.hour,
        checkInTime.minute,
      );

      final shiftStart = DateTime(
        now.year,
        now.month,
        now.day,
        8,
        0,
      ); // JAM 8:00

      if (fullCheckInDate.isAfter(shiftStart)) {
        final difference = fullCheckInDate.difference(shiftStart).inMinutes;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, size: 14, color: Colors.red),
              SizedBox(width: 4),
              Text(
                "LATE ($difference min)",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "ON TIME",
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      }
    } catch (e) {
      return SizedBox();
    }
  }

  Widget _buildHeaderCard(
    String userName,
    String checkInTime,
    String checkOutTime,
    bool isLoading,
  ) {
    final String greeting = _getGreeting();
    final String bgImage = _getHeaderBackgroundImage();

    // 1. Ambil Data & Hitung Style Status
    final todayData = context.watch<AttendanceProvider>().todayStatus;
    final statusEnum = _getTodayStatus(todayData);
    final style = _getStatusStyle(statusEnum);

    String startH = _shiftStartHour.toString().padLeft(2, '0');
    String startM = _shiftStartMinute.toString().padLeft(2, '0');
    String endH = _shiftEndHour.toString().padLeft(2, '0');

    // TEKS DINAMIS: Kalau variabel _shiftStartHour diubah, teks ini otomatis berubah
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
                greeting,
                style: TextStyle(
                  color: AppColor.retroCream.withOpacity(0.9),
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 10.0,
                      color: Colors.black,
                    ),
                  ],
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
              shadows: [
                Shadow(
                  offset: Offset(0, 0),
                  blurRadius: 10.0,
                  color: Colors.black,
                ),
              ],
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    _buildStatusColumn("Check-In", checkInTime),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColor.retroCream.withOpacity(0.5),
                    ),
                    _buildStatusColumn("Check-Out", checkOutTime),
                  ],
                ),

                const SizedBox(height: 12),

                Divider(
                  color: AppColor.retroCream.withOpacity(0.3),
                  thickness: 1,
                ),
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
                        letterSpacing: 0.5,
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

    if (hasCheckedIn && hasCheckedOut) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 48, color: Colors.green[700]),
            const SizedBox(height: 12),
            Text(
              "You've completed your work today!",
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Have a good rest.",
              style: TextStyle(color: Colors.green[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    final bool isCheckInDisabled =
        isCheckingIn || isCheckingOut || hasCheckedIn;

    final bool isCheckOutDisabled =
        isCheckingIn || isCheckingOut || !hasCheckedIn || hasCheckedOut;

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: isCheckingIn ? "Loading..." : "Check In",
            icon: isCheckingIn ? Icons.hourglass_empty : Icons.login,
            isPrimary: true,
            isDisabled: isCheckInDisabled,
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
            isDisabled: isCheckOutDisabled,
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
