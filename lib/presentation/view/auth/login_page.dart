import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/utils/preference_handler.dart';
import 'package:project_absensi_ppkd_b4/core/utils/validator_helper.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_primary_button.dart';
import 'package:project_absensi_ppkd_b4/presentation/common_widgets/custom_text_form_field.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/forgot_password_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/register_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/widgets/auth_footer.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/widgets/auth_header.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/main/main_page.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final String? token = await authProvider.handleLogin(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (token != null) {
      await PreferenceHandler.saveLoginStatus(true);
      await PreferenceHandler.saveToken(token);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (authProvider.errorMessage ?? 'Login failed').replaceAll(
              "Exception: ",
              "",
            ),
          ),
          backgroundColor: AppColor.retroDarkRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColor.retroCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthHeader(title: 'Welcome Back'),

                const SizedBox(height: 48),

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: AppColor.kBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextFormField(
                            label: 'Email Address',
                            controller: _emailController,
                            hintText: 'your.email@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidatorHelper.validateEmail,
                          ),
                          const SizedBox(height: 24),

                          CustomTextFormField(
                            label: 'Password',
                            controller: _passwordController,
                            hintText: '********',
                            obscureText: !_isPasswordVisible,
                            validator: (val) =>
                                ValidatorHelper.validateRequired(
                                  val,
                                  'Password',
                                ),
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

                          CustomPrimaryButton(
                            text: 'Sign In',
                            isLoading: authProvider.isLoading,
                            onPressed: _login,
                          ),

                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 24),

                          AuthFooter(
                            text: "Don't have an account? ",
                            actionText: "Register",
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColor.retroMediumRed.withOpacity(0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('or', style: TextStyle(color: AppColor.retroMediumRed)),
        ),
        Expanded(
          child: Divider(color: AppColor.retroMediumRed.withOpacity(0.5)),
        ),
      ],
    );
  }
}
