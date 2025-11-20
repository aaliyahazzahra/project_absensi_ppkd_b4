import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/enums/attendance_status.dart';
import 'package:project_absensi_ppkd_b4/core/utils/history_helper.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/history_card_item.dart';
import 'widgets/history_filter_section.dart';
import 'widgets/history_header_section.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: Column(
        children: [
          HistoryHeaderSection(
            currentMonth: _currentMonth,
            onPreviousMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
            onSelectMonth: _showMonthPicker,
          ),

          HistoryFilterSection(
            selectedFilter: _selectedStatusFilter,
            onFilterChanged: (status) {
              setState(() => _selectedStatusFilter = status);
            },
          ),

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
                if (_selectedStatusFilter == AttendanceStatus.all) return true;
                final itemStatus = HistoryHelper.getStatusFromApi(item);
                return itemStatus == _selectedStatusFilter;
              }).toList();

              if (filteredHistory.isEmpty) {
                String statusText =
                    _selectedStatusFilter == AttendanceStatus.all
                    ? ""
                    : HistoryHelper.getStatusDisplay(_selectedStatusFilter);

                return Expanded(
                  child: Center(
                    child: Text(
                      'No $statusText attendance history for ${DateFormat('MMMM yyyy').format(_currentMonth)}.',
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
                    return HistoryCardItem(item: item);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
