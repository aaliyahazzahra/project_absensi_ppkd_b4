import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/edit_profile_page.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';
import 'package:provider/provider.dart';
// TODO: Ganti dengan path Halaman Edit Profile Anda yang sebenarnya

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final bool isLoading = provider.isLoading;
        final String? errorMessage = provider.errorMessage;
        final user = provider.userProfile;

        return Scaffold(
          backgroundColor: AppColor.retroCream,
          body: Column(
            children: [
              _buildProfileHeader(
                isLoading ? "Memuat..." : (user?.name ?? "Nama Tidak Tersedia"),
                isLoading
                    ? "Memuat..."
                    : (user?.email ?? "Email Tidak Tersedia"),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.person_outline,
                        title: "Personal Information",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuTile(
                        icon: Icons.settings_outlined,
                        title: "Settings",
                        onTap: () {},
                      ),
                      _buildMenuTile(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        onTap: () {},
                      ),
                      _buildMenuTile(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildMenuTile(
                        icon: Icons.logout,
                        title: "Logout",
                        isLogout: true,
                        onTap: () {
                          // TODO: Implement logic Logout (Tugas 5.1)
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),

              if (errorMessage != null && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(String name, String email) {
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
            Text(
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColor.retroCream,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColor.retroMediumRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColor.retroCream,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      color: AppColor.retroCream.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
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
