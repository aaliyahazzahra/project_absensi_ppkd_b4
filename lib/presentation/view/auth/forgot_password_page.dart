import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/reset_password_page.dart';
import 'package:project_absensi_ppkd_b4/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail(AuthProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;

    final isSuccess = await provider.handleRequestOtp(email: email);

    if (!mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent! Check your email to proceed.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.otpErrorMessage ?? 'Failed to request OTP.'),
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
                onTap: () {
                  Navigator.pop(context);
                },
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
              Icon(Icons.mail_outline, size: 80, color: AppColor.retroDarkRed),
              const SizedBox(height: 16),

              Text(
                'Reset Password',
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
                'Enter your email address and we\'ll send\nyou instructions (OTP) to reset your password', // Teks diperbarui
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
                        final isLoading = provider.isLoadingOtp;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: AppColor.retroDarkRed,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'your.email@example.com',
                                hintStyle: TextStyle(
                                  color: AppColor.retroMediumRed.withOpacity(
                                    0.6,
                                  ),
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
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: AppColor.retroDarkRed),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email cannot be empty.';
                                }
                                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

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
                                  : () => _sendResetEmail(provider),
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
                                      'Send Reset Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(height: 24),

                            GestureDetector(
                              onTap: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                              child: Text(
                                'Return to Sign In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColor.retroLightRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
}
