import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(AuthProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final isSuccess = await provider.handleResetPassword(
      email: widget.email,
      otp: _otpController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.resetPasswordErrorMessage ?? 'Failed to reset password',
          ),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 48),

              Icon(
                Icons.lock_open_outlined,
                size: 80,
                color: AppColor.retroDarkRed,
              ),
              const SizedBox(height: 16),

              Text(
                'New Password',
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
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 140,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Enter the 6-digit OTP sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.retroMediumRed,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: AppColor.kBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Consumer<AuthProvider>(
                      builder: (context, provider, child) {
                        final isLoading = provider.isResettingPassword;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel('OTP (6-digit)'),
                            _buildTextFormField(
                              _otpController,
                              'Enter OTP',
                              TextInputType.number,
                              (value) => (value == null || value.length != 6)
                                  ? 'OTP must be 6 digits.'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            _buildLabel('New Password'),
                            _buildTextFormField(
                              _passwordController,
                              'Enter new password',
                              TextInputType.visiblePassword,
                              (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters.';
                                }
                                return null;
                              },
                              isObscure: true,
                            ),
                            const SizedBox(height: 24),

                            _buildLabel('Confirm Password'),
                            _buildTextFormField(
                              _confirmPasswordController,
                              'Re-enter new password',
                              TextInputType.visiblePassword,
                              (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match.';
                                }
                                return null;
                              },
                              isObscure: true,
                            ),
                            const SizedBox(height: 32),

                            // Reset Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.retroDarkRed,
                                foregroundColor: AppColor.retroCream,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () => _resetPassword(provider),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColor.retroCream,
                                            ),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColor.retroDarkRed,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String hintText,
    TextInputType keyboardType,
    String? Function(String?) validator, {
    bool isObscure = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColor.retroMediumRed.withOpacity(0.6),
            ),
            filled: true,
            fillColor: AppColor.retroCream.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          style: TextStyle(color: AppColor.retroDarkRed),
          obscureText: isObscure,
          validator: validator,
        ),
      ],
    );
  }
}
