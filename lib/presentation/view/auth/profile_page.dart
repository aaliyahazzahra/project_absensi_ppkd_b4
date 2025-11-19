import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/login_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/edit_profile_page.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';
import 'package:provider/provider.dart';

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

  Future<void> _logout(ProfileProvider provider) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColor.retroDarkRed),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final isSuccess = await provider.handleLogout();

    if (!mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout successful.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.logoutErrorMessage ?? 'Failed to logout.'),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final bool isLoading = provider.isLoading;
        final String? errorMessage = provider.errorMessage;
        final user = provider.userProfile;
        final profilePhotoUrl = user?.profilePhoto;

        return Scaffold(
          backgroundColor: AppColor.retroCream,
          body: Column(
            children: [
              _buildProfileHeader(
                name: isLoading
                    ? "Loading..."
                    : (user?.name ?? "Name Not Available"),
                email: isLoading
                    ? "Loading..."
                    : (user?.email ?? "Email Not Available"),
                photoUrl: profilePhotoUrl,
                isLoading: isLoading,
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
                        onTap: () => _logout(provider),
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

  Widget _buildProfileHeader({
    required String name,
    required String email,
    String? photoUrl,
    required bool isLoading,
  }) {
    // --- Widget untuk Foto Profil ---
    Widget profilePhotoWidget = CircleAvatar(
      radius: 40,
      backgroundColor: AppColor.retroCream,
      child: isLoading
          ? const CircularProgressIndicator(color: AppColor.retroMediumRed)
          : (photoUrl != null && photoUrl.isNotEmpty)
          ? ClipOval(
              child: Image.network(
                photoUrl,
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
    // ---------------------------------

    // --- Widget untuk Nama dan Email ---
    Widget nameAndEmailWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align teks ke kiri
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
    // ------------------------------------

    // --- Struktur Utama Header ---
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
              // Menggunakan Row: Teks di Kiri, Foto di Kanan
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: nameAndEmailWidget, // Nama dan Email (kiri)
                  ),
                  const SizedBox(width: 16),
                  profilePhotoWidget, // Foto Profil (kanan)
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
    // -----------------------------
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
