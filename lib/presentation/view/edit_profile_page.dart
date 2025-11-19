import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_text_form_field.dart';
import 'package:project_absensi_ppkd_b4/provider/profile_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();

      _nameController.text = profileProvider.userProfile?.name ?? '';
      _emailController.text = profileProvider.userProfile?.email ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(ProfileProvider provider) async {
    // 1. Cek perubahan yang dilakukan
    final bool nameChanged =
        _nameController.text != (provider.userProfile?.name ?? '');
    final bool imageChanged = _selectedImageFile != null;

    // Jika tidak ada perubahan sama sekali
    if (!nameChanged && !imageChanged) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      Navigator.pop(context);
      return;
    }

    bool success = true;

    // 2. Update Nama (jika ada perubahan)
    if (nameChanged) {
      success = await provider.handleUpdateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );
    }

    // 3. Upload Foto (jika ada perubahan DAN update nama sebelumnya berhasil)
    if (success && imageChanged) {
      final uploadSuccess = await provider.handleUploadProfilePhoto(
        _selectedImageFile!,
      );
      // Status akhir adalah hasil dari upload foto jika itu terjadi
      success = uploadSuccess;
    }

    if (!mounted) return;

    // 4. Tampilkan Snackbar berdasarkan hasil akhir
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // Prioritaskan error foto jika ada, lalu error update info
      String errorMessage =
          provider.uploadPhotoErrorMessage ??
          provider.updateErrorMessage ??
          'Failed to update profile';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.retroCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColor.retroDarkRed,
                ),
                title: Text(
                  'Photo Gallery',
                  style: TextStyle(color: AppColor.retroDarkRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: AppColor.retroDarkRed),
                title: Text(
                  'Camera',
                  style: TextStyle(color: AppColor.retroDarkRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChangePhotoCard(),
                  const SizedBox(height: 24),
                  _buildInfoFormCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.retroDarkRed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 24.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppColor.retroCream),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: AppColor.retroCream,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColor.retroCream,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangePhotoCard() {
    final profileProvider = context.watch<ProfileProvider>();
    final currentPhotoUrl = profileProvider.userProfile?.profilePhoto;

    Widget avatarChild;
    if (_selectedImageFile != null) {
      avatarChild = ClipOval(
        child: Image.file(
          _selectedImageFile!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      );
    } else if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          currentPhotoUrl,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person, size: 45, color: AppColor.retroCream),
        ),
      );
    } else {
      avatarChild = Icon(Icons.person, size: 45, color: AppColor.retroCream);
    }

    return GestureDetector(
      onTap: _showImageSourceActionSheet,
      child: _buildBaseCard(
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColor.retroMediumRed,
                  child: avatarChild,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColor.retroDarkRed,
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppColor.retroCream,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Change Photo',
              style: TextStyle(
                color: AppColor.retroDarkRed,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFormCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            label: 'Full Name',
            controller: _nameController,
            hintText: 'Your full name',
          ),
          const SizedBox(height: 24),
          CustomTextFormField(
            label: 'Email Address',
            controller: _emailController,
            hintText: 'your.email@example.com',
            readOnly: true,
            fillColor: Colors.grey[200],
            labelColor: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final bool isLoading = provider.isUpdating || provider.isUploadingPhoto;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.retroDarkRed,
                foregroundColor: AppColor.retroCream,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLoading ? null : () => _saveChanges(provider),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.retroCream,
                        ),
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.kBackgroundColor,
                foregroundColor: AppColor.retroDarkRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColor.retroDarkRed, width: 2),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBaseCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColor.kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.retroMediumRed.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColor.retroMediumRed.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
