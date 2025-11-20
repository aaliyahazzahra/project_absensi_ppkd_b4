import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:provider/provider.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';

import 'widgets/check_in_header.dart';
import '../../common_widgets/attendance_timer_card.dart';
import '../../common_widgets/location_map_section.dart';
import '../../common_widgets/photo_upload_card.dart';
import 'widgets/check_in_button.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  @override
  void deactivate() {
    // Reset lokasi di provider saat user keluar halaman
    context.read<AttendanceProvider>().clearLocationData();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);

    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CheckInHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  AttendanceTimerCard(date: formattedDate, time: formattedTime),
                  const SizedBox(height: 24),
                  const LocationMapSection(),
                  const SizedBox(height: 24),
                  const PhotoUploadCard(),
                ],
              ),
            ),
          ),
          const CheckInButton(),
        ],
      ),
    );
  }
}
