import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isLoading;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    Widget profilePhotoWidget = CircleAvatar(
      radius: 40,
      backgroundColor: AppColor.retroCream,
      child: isLoading
          ? const CircularProgressIndicator(color: AppColor.retroMediumRed)
          : (photoUrl != null && photoUrl!.isNotEmpty)
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 40,
                  color: AppColor.retroMediumRed,
                ),
              ),
            )
          : Icon(Icons.person, size: 40, color: AppColor.retroMediumRed),
    );

    Widget nameAndEmailWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: AppColor.retroCream,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: AppColor.retroCream.withOpacity(0.8),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Profile',
              style: TextStyle(
                color: AppColor.retroCream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColor.retroMediumRed,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: nameAndEmailWidget),
                  const SizedBox(width: 16),
                  profilePhotoWidget,
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
