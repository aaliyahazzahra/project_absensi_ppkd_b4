import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/enums/attendance_status.dart';

class HistoryFilterSection extends StatelessWidget {
  final AttendanceStatus selectedFilter;
  final Function(AttendanceStatus) onFilterChanged;

  const HistoryFilterSection({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Kita hardcode list opsinya di sini agar rapi
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
            final isSelected = selectedFilter == option['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                onPressed: () => onFilterChanged(option['value']),
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
}
