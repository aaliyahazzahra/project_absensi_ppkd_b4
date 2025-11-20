import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/enums/attendance_status.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/today_status_response.dart';

class HomeHelper {
  static const int shiftStartHour = 8;
  static const int shiftStartMinute = 0;
  static const int shiftEndHour = 17;

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Good Morning,';
    if (hour < 15) return 'Good Afternoon,';
    if (hour < 18) return 'Good Evening,';
    return 'Good Night,';
  }

  static String getHeaderBackgroundImage() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'assets/images/morning_banner.png';
    if (hour < 15) return 'assets/images/afternoon_banner.png';
    if (hour < 18) return 'assets/images/evening_banner.png';
    return 'assets/images/night_banner.png';
  }

  static AttendanceStatus getTodayStatus(TodayStatusData? data) {
    if (data == null) return AttendanceStatus.incomplete;

    final status = data.status?.toLowerCase() ?? '';
    final checkIn = data.checkInTime;
    final checkOut = data.checkOutTime;

    if (status.contains('izin') || status.contains('sakit'))
      return AttendanceStatus.izin;
    if (status.contains('weekend') || status.contains('libur'))
      return AttendanceStatus.weekend;
    if (status.contains('late') || status.contains('terlambat'))
      return AttendanceStatus.late;

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
          shiftStartHour,
          shiftStartMinute,
        );

        if (checkInDate.isAfter(shiftStart) && !status.contains('late')) {
          return AttendanceStatus.late;
        }
      } catch (_) {}
    }

    if (checkIn != null && checkOut == null) return AttendanceStatus.incomplete;
    if (checkIn != null && checkOut != null) return AttendanceStatus.present;

    return AttendanceStatus.absent;
  }

  static Map<String, dynamic> getStatusStyle(AttendanceStatus status) {
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
          'text': 'Currently Working',
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
}
