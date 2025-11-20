import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_card.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';

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
            final bool isApiLoading = provider.isCheckingOut;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: CustomCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm Clock Out',
                      style: TextStyle(
                        color: AppColor.retroDarkRed,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to clock out? Your work time will be recorded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.retroMediumRed,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.retroDarkRed,
                        foregroundColor: AppColor.retroCream,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isApiLoading
                          ? null
                          : () => _checkOut(context, dialogContext),
                      child: isApiLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kBackgroundColor,
                        foregroundColor: AppColor.retroDarkRed,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColor.retroDarkRed,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isApiLoading
                          ? null
                          : () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
