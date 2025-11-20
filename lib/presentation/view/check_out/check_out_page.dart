import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/attendance_timer_card.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/location_map_section.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/photo_upload_card.dart';
import 'package:project_absensi_ppkd_b4/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/check_out_button.dart';
import 'widgets/check_out_header.dart';
import 'widgets/check_out_status_box.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  @override
  void deactivate() {
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
          const CheckOutHeader(),

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

          const CheckOutStatusBox(),

          const CheckOutButton(),
        ],
      ),
    );
  }
}
