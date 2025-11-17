import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/main_page.dart';
import 'package:project_absensi_ppkd_b4/service/api.dart';

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

  List<BatchData> _batchList = [];
  List<TrainingData> _trainingList = [];
  int? _selectedBatchId;
  int? _selectedTrainingId;
  String? _selectedJenisKelamin;


  String? _profilePhotoBase64;
  String _profilePhotoName = "Tap to select photo"; 

  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isLoadingLists = true;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  

  Future<void> _loadDropdownData() async {
    try {
      final responses = await Future.wait([
        _apiService.getBatches(),
        _apiService.getTrainings(),
      ]);

      setState(() {
        _batchList = responses[0] as List<BatchData>;
        _trainingList = responses[1] as List<TrainingData>;
        _isLoadingLists = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLists = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load form data: $e'),
            backgroundColor: AppColor.retroDarkRed,
          ),
        );
      }
    }
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

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoadingLists) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      _profilePhotoBase64 ??= "";

      await _apiService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: _selectedJenisKelamin,
        profilePhoto: _profilePhotoBase64!,
        batchId: _selectedBatchId,
        trainingId: _selectedTrainingId,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Register Failed: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: AppColor.retroDarkRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _isLoadingLists
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.retroDarkRed,
                      ),
                    )
                  : _buildRegisterCard(),
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

  Widget _buildRegisterCard() {
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
              _buildTextFieldLabel('Full Name'),
              _buildTextFormField(
                controller: _nameController,
                hintText: 'John Doe',
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Name cannot be empty'
                    : null,
              ),
              const SizedBox(height: 24),

              _buildTextFieldLabel('Email Address'),
              _buildTextFormField(
                controller: _emailController,
                hintText: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Email cannot be empty'
                    : null,
              ),
              const SizedBox(height: 24),

              _buildTextFieldLabel('Gender'),
              DropdownButtonFormField<String>(
                initialValue: _selectedJenisKelamin,
                hint: Text('Select Gender', style: _hintStyle()),
                decoration: _buildInputDecoration(),
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

              _buildTextFieldLabel('Batch'),
              DropdownButtonFormField<int>(
                initialValue: _selectedBatchId,
                isExpanded: true,
                hint: Text('Select Batch', style: _hintStyle()),
                decoration: _buildInputDecoration(),
                items: _batchList.map((BatchData batch) {
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

              _buildTextFieldLabel('Training'),
              DropdownButtonFormField<int>(
                initialValue: _selectedTrainingId,
                isExpanded: true,
                hint: Text('Select Training', style: _hintStyle()),
                decoration: _buildInputDecoration(),
                items: _trainingList.map((TrainingData training) {
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

              _buildTextFieldLabel('Password'),
              _buildTextFormField(
                controller: _passwordController,
                hintText: '********',
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Password cannot be empty'
                    : null,
              ),
              const SizedBox(height: 24),

              _buildTextFieldLabel('Profile Photo (Optional)'),
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
                onPressed: _isLoading ? null : _register,
                child: _isLoading
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

  TextStyle _hintStyle() {
    return TextStyle(color: AppColor.retroMediumRed.withOpacity(0.6));
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColor.retroCream.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: AppColor.retroDarkRed,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration().copyWith(
        hintText: hintText,
        hintStyle: _hintStyle(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: AppColor.retroDarkRed),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
