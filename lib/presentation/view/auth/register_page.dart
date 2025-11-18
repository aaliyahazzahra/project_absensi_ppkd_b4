import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/main_page.dart';
import 'package:project_absensi_ppkd_b4/provider/auth_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/dropdown_provider.dart';

import 'package:provider/provider.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_text_form_field.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_dropdown_form_field.dart';
import 'package:project_absensi_ppkd_b4/models/response/batches_response.dart';
import 'package:project_absensi_ppkd_b4/models/response/training_response.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _selectedBatchId;
  int? _selectedTrainingId;
  String? _selectedJenisKelamin;
  String? _profilePhotoBase64;
  String _profilePhotoName = "Tap to select photo";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DropdownProvider>().fetchDropdownData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _profilePhotoBase64 = "data:image/png;base64,${base64Encode(bytes)}";
        _profilePhotoName = image.name;
      });
    }
  }

  Future<void> _register(AuthProvider authProvider) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedJenisKelamin == null ||
        _selectedBatchId == null ||
        _selectedTrainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
      return;
    }

    final bool isSuccess = await authProvider.handleRegister(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      jenisKelamin: _selectedJenisKelamin,
      profilePhoto: _profilePhotoBase64 ?? "",
      batchId: _selectedBatchId,
      trainingId: _selectedTrainingId,
    );

    if (isSuccess) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        final String errorMessage =
            (authProvider.registerErrorMessage ??
                    'Register failed: Unknown error')
                .replaceAll("Exception: ", "");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColor.retroDarkRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dropdownProvider = context.watch<DropdownProvider>();

    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              dropdownProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.retroDarkRed,
                      ),
                    )
                  : _buildRegisterCard(authProvider, dropdownProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: AppColor.retroDarkRed),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: AppColor.retroDarkRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Icon(Icons.access_time, size: 80, color: AppColor.retroDarkRed),
        const SizedBox(height: 16),
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.retroDarkRed,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: 60,
          height: 2,
          color: AppColor.retroDarkRed,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(
    AuthProvider authProvider,
    DropdownProvider dropdownProvider,
  ) {
    final bool isLoading = authProvider.isRegisterLoading;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColor.kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                label: 'Full Name',
                controller: _nameController,
                hintText: 'John Doe',
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Name cannot be empty'
                    : null,
              ),
              const SizedBox(height: 24),

              CustomTextFormField(
                label: 'Email Address',
                controller: _emailController,
                hintText: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Email cannot be empty'
                    : null,
              ),
              const SizedBox(height: 24),

              CustomDropdownFormField<String>(
                label: 'Gender',
                hintText: 'Select Gender',
                value: _selectedJenisKelamin,
                isExpanded: false,
                items: const [
                  DropdownMenuItem(value: "L", child: Text("Laki-laki")),
                  DropdownMenuItem(value: "P", child: Text("Perempuan")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedJenisKelamin = value;
                  });
                },
                validator: (value) =>
                    (value == null) ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 24),

              CustomDropdownFormField<int>(
                label: 'Batch',
                hintText: 'Select Batch',
                value: _selectedBatchId,
                items: dropdownProvider.batchList.map((Batch batch) {
                  return DropdownMenuItem<int>(
                    value: batch.id,
                    child: Text(
                      "Batch ke - ${batch.batchKe ?? 'N/A'}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBatchId = value;
                  });
                },
                validator: (value) =>
                    (value == null) ? 'Please select a batch' : null,
              ),
              const SizedBox(height: 24),

              CustomDropdownFormField<int>(
                label: 'Training',
                hintText: 'Select Training',
                value: _selectedTrainingId,
                items: dropdownProvider.trainingList.map((Training training) {
                  return DropdownMenuItem<int>(
                    value: training.id,
                    child: Text(
                      training.title ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTrainingId = value;
                  });
                },
                validator: (value) =>
                    (value == null) ? 'Please select a training' : null,
              ),
              const SizedBox(height: 24),

              CustomTextFormField(
                label: 'Password',
                controller: _passwordController,
                hintText: '********',
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Password cannot be empty'
                    : null,
              ),
              const SizedBox(height: 24),

              Text(
                'Profile Photo (Optional)',
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.retroCream.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  leading: Icon(
                    Icons.photo_outlined,
                    color: AppColor.retroDarkRed,
                  ),
                  title: Text(
                    _profilePhotoName,
                    style: TextStyle(
                      color: _profilePhotoBase64 != null
                          ? AppColor.retroDarkRed
                          : AppColor.retroMediumRed.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: _pickImage,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.retroDarkRed,
                  foregroundColor: AppColor.retroCream,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : () => _register(authProvider),
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
                        'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: AppColor.retroDarkRed.withOpacity(0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColor.retroLightRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
