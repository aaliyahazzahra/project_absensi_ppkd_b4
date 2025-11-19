import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/preference_handler.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_text_form_field.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/forgot_password_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/register_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/main_page.dart';
import 'package:project_absensi_ppkd_b4/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ... di dalam _LoginPageState
  Future<void> _login() async {
    final authProvider = context.read<AuthProvider>();

    // Asumsi handleLogin kini mengembalikan token jika sukses
    // Jika tidak, Anda perlu memodifikasi AuthProvider agar token bisa diakses
    final String? token = await authProvider.handleLogin(
      _emailController.text,
      _passwordController.text,
    );

    // Periksa apakah login sukses (asumsi sukses jika token tidak null)
    if (token != null) {
      // 🎯 SIMPAN STATUS LOGIN DAN TOKEN
      await PreferenceHandler.saveLoginStatus(true);
      await PreferenceHandler.saveToken(token);

      if (mounted) {
        // Navigasi ke MainPage (rute '/home' harus mengarah ke MainPage)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        final String errorMessage =
            (authProvider.errorMessage ?? 'Login failed: Unknown error')
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
    final bool isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(Icons.access_time, size: 80, color: AppColor.retroDarkRed),
              const SizedBox(height: 16),
              Text(
                'PRESENTIA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.retroDarkRed,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Container(
                width: 60,
                height: 2,
                color: AppColor.retroDarkRed,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              Text(
                'Elegant Time Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.retroMediumRed,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 48),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: AppColor.kBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.retroDarkRed,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      const SizedBox(height: 8),
                      CustomTextFormField(
                        label: 'Email Address',
                        controller: _emailController,
                        hintText: 'your.email@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),

                      const SizedBox(height: 8),
                      CustomTextFormField(
                        label: 'Password',
                        controller: _passwordController,
                        hintText: '********',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColor.retroLightRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

                        onPressed: isLoading ? null : _login,
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
                                'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColor.retroMediumRed.withOpacity(0.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'or',
                              style: TextStyle(color: AppColor.retroMediumRed),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColor.retroMediumRed.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: AppColor.retroDarkRed.withOpacity(0.7),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Register',
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
            ],
          ),
        ),
      ),
    );
  }
}
