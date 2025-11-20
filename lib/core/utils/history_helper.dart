import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/enums/attendance_status.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/history_response.dart';

class HistoryHelper {
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static AttendanceStatus getStatusFromApi(HistoryData item) {
    final status = item.status.toLowerCase();

    if (status.contains('izin') ||
        (status.contains('absen') && item.alasanIzin != null)) {
      return AttendanceStatus.izin;
    }
    if (status.contains('absen') ||
        (item.checkInTime == null && item.alasanIzin == null)) {
      return AttendanceStatus.absent;
    }
    if (status.contains('weekend') ||
        status.contains('libur') ||
        isWeekend(item.attendanceDate)) {
      return AttendanceStatus.weekend;
    }
    if (item.checkInTime != null && item.checkOutTime == null) {
      return AttendanceStatus.incomplete;
    }
    if (status.contains('late') || status.contains('terlambat')) {
      return AttendanceStatus.late;
    }
    return AttendanceStatus.present;
  }

  static String getStatusDisplay(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.all:
        return 'All';
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.weekend:
        return 'Holiday';
      case AttendanceStatus.incomplete:
        return 'Not Checked Out';
      case AttendanceStatus.izin:
        return 'Leave/Sick';
    }
  }

  static Map<String, dynamic> getStatusStyle(AttendanceStatus status) {
    final Map<String, dynamic> baseStyle = {
      'text': getStatusDisplay(status),
      'color': AppColor.retroMediumRed,
      'textColor': AppColor.retroDarkRed,
      'borderColor': AppColor.retroMediumRed.withOpacity(0.2),
      'shadowColor': AppColor.retroMediumRed.withOpacity(0.1),
    };

    switch (status) {
      case AttendanceStatus.all:
        baseStyle['text'] = 'All Status';
        baseStyle['color'] = Colors.blueGrey[100];
        baseStyle['textColor'] = Colors.blueGrey[800];
        baseStyle['borderColor'] = Colors.blueGrey.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.blueGrey.withOpacity(0.1);
        break;
      case AttendanceStatus.present:
        baseStyle['color'] = Colors.green;
        baseStyle['textColor'] = Colors.green[800];
        baseStyle['borderColor'] = Colors.green.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.green.withOpacity(0.1);
        break;
      case AttendanceStatus.absent:
        baseStyle['color'] = AppColor.retroMediumRed;
        baseStyle['textColor'] = AppColor.retroDarkRed;
        baseStyle['borderColor'] = AppColor.retroDarkRed.withOpacity(0.5);
        break;
      case AttendanceStatus.late:
        baseStyle['color'] = Colors.orange;
        baseStyle['textColor'] = Colors.orange[800];
        baseStyle['borderColor'] = Colors.orange.withOpacity(0.5);
        break;
      case AttendanceStatus.weekend:
        baseStyle['text'] = 'Weekend/Holiday';
        baseStyle['color'] = AppColor.retroLightRed;
        baseStyle['textColor'] = AppColor.retroMediumRed;
        break;
      case AttendanceStatus.incomplete:
        baseStyle['color'] = Colors.blueGrey;
        baseStyle['textColor'] = Colors.blueGrey[700];
        baseStyle['borderColor'] = Colors.blueGrey.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.blueGrey.withOpacity(0.1);
        break;
      case AttendanceStatus.izin:
        baseStyle['color'] = Colors.amber;
        baseStyle['textColor'] = Colors.amber[800];
        baseStyle['borderColor'] = Colors.amber.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.amber.withOpacity(0.1);
        break;
    }
    return baseStyle;
  }

  static String formatTime(String? timeStr, DateTime date) {
    if (timeStr == null || timeStr.isEmpty) return '--';
    try {
      final time = DateTime.parse(
        '${date.toIso8601String().split('T').first} $timeStr',
      );
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return timeStr;
    }
  }
}
