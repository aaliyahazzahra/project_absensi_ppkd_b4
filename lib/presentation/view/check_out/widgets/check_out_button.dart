import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_confirmation_dialog.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

class CheckOutButton extends StatelessWidget {
  const CheckOutButton({super.key});

  Future<void> _checkOut(
    BuildContext context,
    BuildContext dialogContext,
  ) async {
    final provider = context.read<AttendanceProvider>();
    final position = provider.capturedPosition;
    final address = provider.capturedAddress;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location not available. Cannot clock out."),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final String attendanceDate = DateFormat('yyyy-MM-dd').format(now);
    final String checkOutTime = DateFormat('HH:mm').format(now);

    final bool isSuccess = await provider.handleCheckOut(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address ?? "Unknown Address",
      attendanceDate: attendanceDate,
      checkOutTime: checkOutTime,
    );

    if (!context.mounted) return;
    Navigator.pop(dialogContext);

    if (isSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Check-out successful!"),
          backgroundColor: Colors.green[700],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-out Failed: ${provider.checkOutErrorMessage?.replaceAll("Exception: ", "")}',
          ),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !context.read<AttendanceProvider>().isCheckingOut,
      builder: (BuildContext dialogContext) {
        return Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            return CustomConfirmationDialog(
              title: 'Confirm Clock Out',
              content:
                  'Are you sure you want to clock out? Your work time will be recorded.',
              confirmText: 'Confirm',
              confirmColor: AppColor.retroDarkRed,
              isLoading: provider.isCheckingOut,
              onCancel: () => Navigator.pop(dialogContext),
              onConfirm: () async {
                await _checkOut(context, dialogContext);
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
        final bool isButtonDisabled =
            provider.capturedPosition == null || provider.isCheckingOut;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          color: AppColor.retroCream,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Clock Out Now',
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
