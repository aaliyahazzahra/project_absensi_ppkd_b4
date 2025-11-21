import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/utils/validator_helper.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/batches_response.dart';
import 'package:project_absensi_ppkd_b4/data/models/response/training_response.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_dropdown_form_field.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_primary_button.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_text_form_field.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/auth_back_button.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/login_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/widgets/auth_footer.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/widgets/auth_header.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/widgets/register_photo_picker.dart';
import 'package:project_absensi_ppkd_b4/provider/auth_provider.dart';
import 'package:project_absensi_ppkd_b4/provider/dropdown_provider.dart';
import 'package:provider/provider.dart';

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
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropdownProvider = context.read<DropdownProvider>();
      if (dropdownProvider.batchList.isEmpty) {
        dropdownProvider.fetchDropdownData();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool isSuccess = await authProvider.handleRegister(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      jenisKelamin: _selectedJenisKelamin,
      profilePhoto: _profilePhotoBase64 ?? "",
      batchId: _selectedBatchId,
      trainingId: _selectedTrainingId,
    );

    if (!mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success! Please login.'),
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
          content: Text(authProvider.registerErrorMessage ?? 'Error'),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  // --- UI Methods ---

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
              AuthBackButton(onPressed: () => Navigator.pop(context)),

              const SizedBox(height: 24),

              const AuthHeader(title: 'Create Account'),

              const SizedBox(height: 32),

              dropdownProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColor.retroDarkRed,
                      ),
                    )
                  : _buildRegisterForm(authProvider, dropdownProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(
    AuthProvider authProvider,
    DropdownProvider dropdownProvider,
  ) {
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
                validator: ValidatorHelper.validateName,
              ),
              const SizedBox(height: 24),

              CustomTextFormField(
                label: 'Email',
                controller: _emailController,
                hintText: 'email@example.com',
                validator: ValidatorHelper.validateEmail,
              ),
              const SizedBox(height: 24),

              CustomDropdownFormField<String>(
                label: 'Gender',
                hintText: 'Select Gender',
                value: _selectedJenisKelamin,
                items: const [
                  DropdownMenuItem(value: "L", child: Text("Laki-laki")),
                  DropdownMenuItem(value: "P", child: Text("Perempuan")),
                ],
                onChanged: (v) => setState(() => _selectedJenisKelamin = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              CustomDropdownFormField<int>(
                label: 'Batch',
                hintText: 'Select Batch',
                value: _selectedBatchId,
                items: dropdownProvider.batchList.map((Batch b) {
                  return DropdownMenuItem(
                    value: b.id,
                    child: Text("Batch ${b.batchKe}"),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedBatchId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              CustomDropdownFormField<int>(
                label: 'Training',
                hintText: 'Select Training',
                value: _selectedTrainingId,
                items: dropdownProvider.trainingList.map((Training t) {
                  return DropdownMenuItem(
                    value: t.id,
                    child: Text(t.title ?? '-'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedTrainingId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              CustomTextFormField(
                label: 'Password',
                controller: _passwordController,
                hintText: '******',
                obscureText: !_isPasswordVisible,
                validator: ValidatorHelper.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColor.retroMediumRed,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              RegisterPhotoPicker(
                photoName: _profilePhotoName,
                hasImage: _profilePhotoBase64 != null,
                onTap: _pickImage,
              ),

              const SizedBox(height: 32),

              CustomPrimaryButton(
                text: 'Register',
                isLoading: authProvider.isRegisterLoading,
                onPressed: () => _register(authProvider),
              ),

              const SizedBox(height: 24),

              AuthFooter(
                text: "Already have an account? ",
                actionText: "Sign In",
                onActionTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
