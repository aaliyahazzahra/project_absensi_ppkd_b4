import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
// Import halaman CheckIn dan CheckOut
import 'package:project_absensi_ppkd_b4/presentation/view/check_in/check_in_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/check_out/check_out_page.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback
  onRefreshData; // Callback untuk refresh data setelah balik dari halaman lain

  const HomeActionButtons({super.key, required this.onRefreshData});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final todayStatus = attendanceProvider.todayStatus;

    final bool hasCheckedIn = todayStatus?.checkInTime != null;
    final bool hasCheckedOut = todayStatus?.checkOutTime != null;
    final bool isCheckingIn = attendanceProvider.isCheckingIn;
    final bool isCheckingOut = attendanceProvider.isCheckingOut;

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
          child: _buildButton(
            context,
            label: isCheckingIn ? "Loading..." : "Check In",
            icon: isCheckingIn ? Icons.hourglass_empty : Icons.login,
            isPrimary: true,
            isDisabled: isCheckInDisabled,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckInPage()),
              );
              onRefreshData();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(
            context,
            label: isCheckingOut ? "Loading..." : "Check Out",
            icon: isCheckingOut ? Icons.hourglass_empty : Icons.logout,
            isPrimary: false,
            isDisabled: isCheckOutDisabled,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckOutPage()),
              );
              onRefreshData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
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
              : (isPrimary ? AppColor.retroDarkRed : AppColor.kBackgroundColor),
          foregroundColor: isDisabled
              ? Colors.grey[600]
              : (isPrimary ? AppColor.retroCream : AppColor.retroDarkRed),
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
}
