import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/models/response/history_response.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

enum AttendanceStatus { all, present, absent, late, weekend, incomplete, izin }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _currentMonth = DateTime.now();
  AttendanceStatus _selectedStatusFilter = AttendanceStatus.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  void _fetchHistory() {
    context.read<AttendanceProvider>().fetchAttendanceHistory();
  }

  void _changeMonth(int months) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + months,
        1,
      );
    });
  }

  Future<void> _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Select Month and Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColor.retroDarkRed,
            colorScheme: ColorScheme.light(primary: AppColor.retroDarkRed),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  AttendanceStatus _getStatusFromApi(HistoryData item) {
    final status = item.status.toLowerCase() ?? '';

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
        dateIsWeekend(item.attendanceDate)) {
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

  bool dateIsWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: Column(
        children: [
          _buildHeader(),

          _buildSegmentedStatusFilter(),

          Consumer<AttendanceProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingHistory) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.retroDarkRed,
                    ),
                  ),
                );
              }

              if (provider.historyErrorMessage != null) {
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error: Failed to load history\n${provider.historyErrorMessage?.replaceAll("Exception: ", "")}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.retroDarkRed,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final historyData = provider.historyList ?? [];

              final monthFiltered = historyData.where((item) {
                final itemDate = item.attendanceDate;
                return itemDate.year == _currentMonth.year &&
                    itemDate.month == _currentMonth.month;
              });

              final filteredHistory = monthFiltered.where((item) {
                if (_selectedStatusFilter == AttendanceStatus.all) {
                  return true;
                }
                final itemStatus = _getStatusFromApi(item);
                return itemStatus == _selectedStatusFilter;
              }).toList();

              if (filteredHistory.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'No ${_getStatusDisplay(_selectedStatusFilter)} attendance history for ${DateFormat('MMMM yyyy').format(_currentMonth)}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.retroMediumRed,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              filteredHistory.sort(
                (a, b) => b.attendanceDate.compareTo(a.attendanceDate),
              );

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20,
                  ),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];

                    final DateTime date = item.attendanceDate;

                    final String dayOfWeek = DateFormat('E').format(date);
                    final String dayOfMonth = DateFormat('dd').format(date);

                    String formatTime(String? timeStr) {
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

                    final String checkInTime = formatTime(item.checkInTime);
                    final String checkOutTime = formatTime(item.checkOutTime);

                    final status = _getStatusFromApi(item);

                    return _buildHistoryItem(
                      day: dayOfWeek,
                      date: dayOfMonth,
                      checkIn: checkInTime,
                      checkOut: checkOutTime,
                      status: status,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedStatusFilter() {
    final List<Map<String, dynamic>> statusOptions = [
      {'value': AttendanceStatus.all, 'label': 'All'},
      {'value': AttendanceStatus.present, 'label': 'Present'},
      {'value': AttendanceStatus.late, 'label': 'Late'},
      {'value': AttendanceStatus.izin, 'label': 'Leave/Sick'},
      {'value': AttendanceStatus.absent, 'label': 'Absent'},
      {'value': AttendanceStatus.incomplete, 'label': 'Not Checked Out'},
      {'value': AttendanceStatus.weekend, 'label': 'Holiday'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statusOptions.map((option) {
            final isSelected = _selectedStatusFilter == option['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                onPressed: () {
                  setState(() {
                    _selectedStatusFilter = option['value'];
                  });
                },
                label: Text(option['label']),
                backgroundColor: isSelected
                    ? AppColor.retroDarkRed
                    : AppColor.retroCream,
                side: BorderSide(
                  color: isSelected
                      ? AppColor.retroDarkRed
                      : AppColor.retroMediumRed.withOpacity(0.5),
                  width: isSelected ? 1.5 : 1.0,
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColor.retroCream
                      : AppColor.retroDarkRed,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
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
          const Text(
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
                GestureDetector(
                  onTap: () => _changeMonth(-1),
                  child: Icon(Icons.chevron_left, color: AppColor.retroCream),
                ),

                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_currentMonth),
                        style: TextStyle(
                          color: AppColor.retroCream,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        color: AppColor.retroCream,
                        size: 16,
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => _changeMonth(1),
                  child: Icon(Icons.chevron_right, color: AppColor.retroCream),
                ),
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
        border: Border.all(color: statusStyle['borderColor'] as Color),
        boxShadow: [
          BoxShadow(
            color: statusStyle['shadowColor'] as Color,
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
              color: statusStyle['color'] as Color,
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
                    color: statusStyle['textColor'],
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

  String _getStatusDisplay(AttendanceStatus status) {
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

  Map<String, dynamic> _getStatusStyle(AttendanceStatus status) {
    final Map<String, dynamic> baseStyle = {
      'text': _getStatusDisplay(status),
      'color': AppColor.retroMediumRed,
      'textColor': AppColor.retroDarkRed,
      'borderColor': AppColor.retroMediumRed.withOpacity(0.2),
      'shadowColor': AppColor.retroMediumRed.withOpacity(0.1),
    };

    switch (status) {
      case AttendanceStatus.all:
      case AttendanceStatus.present:
        baseStyle['text'] = 'Present';
        baseStyle['color'] = Colors.green;
        baseStyle['textColor'] = Colors.green[800];
        baseStyle['borderColor'] = Colors.green.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.green.withOpacity(0.1);
        break;
      case AttendanceStatus.absent:
        baseStyle['text'] = 'Absent';
        baseStyle['color'] = AppColor.retroMediumRed;
        baseStyle['textColor'] = AppColor.retroDarkRed;
        baseStyle['borderColor'] = AppColor.retroDarkRed.withOpacity(0.5);
        break;
      case AttendanceStatus.late:
        baseStyle['text'] = 'Late';
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
        baseStyle['text'] = 'Not Checked Out';
        baseStyle['color'] = Colors.blueGrey;
        baseStyle['textColor'] = Colors.blueGrey[700];
        baseStyle['borderColor'] = Colors.blueGrey.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.blueGrey.withOpacity(0.1);
        break;
      case AttendanceStatus.izin:
        baseStyle['text'] = 'Leave/Sick';
        baseStyle['color'] = Colors.amber;
        baseStyle['textColor'] = Colors.amber[800];
        baseStyle['borderColor'] = Colors.amber.withOpacity(0.5);
        baseStyle['shadowColor'] = Colors.amber.withOpacity(0.1);
        break;
    }
    return baseStyle;
  }
}
