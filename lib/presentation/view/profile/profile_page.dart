import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
// Import Dialog Reusable
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_confirmation_dialog.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/login_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/profile/edit_profile_page.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';
import 'package:provider/provider.dart';

// Import Widget Pecahan
import 'widgets/profile_header_section.dart';
import 'widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isInitialFetchDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ProfileProvider>();

    if (!_isInitialFetchDone &&
        provider.userProfile == null &&
        !provider.isLoading &&
        !provider.isLoggingOut) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          provider.fetchProfileData().then((_) => _isInitialFetchDone = true);
        }
      });
    }
  }

  Future<void> _showLogoutDialog(ProfileProvider provider) async {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: 'Confirm Logout',
        content: 'Are you sure you want to log out?',
        confirmText: 'Logout',
        confirmColor: AppColor.retroDarkRed,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          // Tutup dialog dulu biar gak numpuk saat proses async
          Navigator.pop(context);

          // Tampilkan loading indicator overlay atau biarkan user menunggu sebentar
          // Tapi karena kita pakai provider, kita bisa panggil fungsi logout langsung

          final isSuccess = await provider.handleLogout();
          if (!mounted) return;

          if (isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logout successful.'),
                backgroundColor: Colors.green,
              ),
            );
            _isInitialFetchDone = false;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.logoutErrorMessage ?? 'Failed to logout.',
                ),
                backgroundColor: AppColor.retroDarkRed,
              ),
            );
          }
        },
      ),
    );
  }

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
              // 1. Header
              ProfileHeaderSection(
                name: isLoading
                    ? "Loading..."
                    : (user?.name ?? "Name Not Available"),
                email: isLoading
                    ? "Loading..."
                    : (user?.email ?? "Email Not Available"),
                photoUrl: user?.profilePhoto,
                isLoading: isLoading,
              ),

              // 2. Menu List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      ProfileMenuItem(
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
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: "Settings",
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: "Logout",
                        isLogout: true,
                        onTap: () => _showLogoutDialog(provider),
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading &&
                  user == null) // Loading indikator jika data belum ada
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: CircularProgressIndicator(),
                ),

              if (errorMessage != null && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
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
}
