import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double iconSize;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/logofull.png', height: 100),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.retroDarkRed,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.retroMediumRed, fontSize: 14),
          ),
        ],
        Container(
          width: 60,
          height: 2,
          color: AppColor.retroDarkRed,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ],
    );
  }
}
