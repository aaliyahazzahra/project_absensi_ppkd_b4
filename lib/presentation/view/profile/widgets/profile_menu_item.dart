import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isLogout
        ? AppColor.retroMediumRed
        : AppColor.retroDarkRed;
    final Color iconColor = isLogout
        ? AppColor.retroMediumRed
        : AppColor.retroDarkRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColor.kBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.retroMediumRed.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColor.retroMediumRed.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: isLogout ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (!isLogout)
                  Icon(Icons.chevron_right, color: AppColor.retroLightRed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
