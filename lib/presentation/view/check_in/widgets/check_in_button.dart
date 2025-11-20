import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_confirmation_dialog.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key});

  Future<void> _checkIn(
    BuildContext context,
    BuildContext dialogContext,
  ) async {
    final provider = context.read<AttendanceProvider>();
    final position = provider.capturedPosition;
    final address = provider.capturedAddress;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location not available. Cannot clock in."),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final String attendanceDate = DateFormat('yyyy-MM-dd').format(now);
    final String checkInTime = DateFormat('HH:mm').format(now);

    final bool isSuccess = await provider.handleCheckIn(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address ?? "Unknown Address",
      attendanceDate: attendanceDate,
      checkInTime: checkInTime,
      status: "masuk",
    );

    if (!context.mounted) return;
    Navigator.pop(dialogContext);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Check-in successful!"),
          backgroundColor: Colors.green[700],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in Failed: ${provider.checkInErrorMessage?.replaceAll("Exception: ", "")}',
          ),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    final String confirmTime = DateFormat('hh:mm:ss a').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: !context.read<AttendanceProvider>().isCheckingIn,
      builder: (BuildContext dialogContext) {
        return Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            return CustomConfirmationDialog(
              title: 'Confirm Clock In',
              content: 'Are you sure you want to clock in at $confirmTime?',
              confirmText: 'Confirm',
              confirmColor: AppColor.retroDarkRed,
              isLoading: provider.isCheckingIn,
              onCancel: () => Navigator.pop(dialogContext),
              onConfirm: () async {
                await _checkIn(context, dialogContext);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final bool isApiLoading = provider.isCheckingIn;
        final bool isButtonDisabled =
            provider.capturedPosition == null || isApiLoading;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: AppColor.retroCream,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Clock In Now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonDisabled
                  ? Colors.grey[400]
                  : AppColor.retroDarkRed,
              foregroundColor: AppColor.retroCream,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isButtonDisabled
                ? null
                : () => _showConfirmationDialog(context),
          ),
        );
      },
    );
  }
}
