import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/home_action_buttons.dart';
import 'widgets/home_header_section.dart';
import 'widgets/home_weekly_stats_card.dart';
import 'widgets/home_working_hours_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isInitialLoading = true);

    try {
      final provider = context.read<AttendanceProvider>();
      await context.read<ProfileProvider>().fetchProfileData();
      await provider.fetchTodayStatusData();

      final now = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd');
      provider.fetchAttendanceStats(
        startDate: formatter.format(now.subtract(const Duration(days: 6))),
        endDate: formatter.format(now),
      );
    } catch (e) {
      debugPrint('Error fetching initial data: $e');
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeHeaderSection(
              userName: profileProvider.userProfile?.name ?? "User",
              todayStatus: attendanceProvider.todayStatus,
              isLoading: attendanceProvider.isLoadingStatus,
            ),

            const SizedBox(height: 24),

            HomeActionButtons(onRefreshData: _fetchInitialData),

            const SizedBox(height: 24),

            HomeWorkingHoursCard(
              workingHours: attendanceProvider.totalWorkingHoursToday,
              isLoading: attendanceProvider.isLoadingStatus,
            ),

            const SizedBox(height: 24),

            HomeWeeklyStatsCard(
              isLoading: attendanceProvider.isLoadingStats,
              stats: attendanceProvider.statsData,
            ),
          ],
        ),
      ),
    );
  }
}
