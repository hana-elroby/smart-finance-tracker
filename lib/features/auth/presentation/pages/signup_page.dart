// Sign Up Page - صفحة إنشاء حساب
// Handles new user registration

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'otp_verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFE8EAF6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
            if (state.status == AuthStatus.otpRequired) {
              // Navigate to OTP verification
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuthBloc>(),
                    child: OtpVerificationPage(email: _emailController.text.trim()),
                  ),
                ),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'Full Name',
                                controller: _fullNameController,
                                hint: 'John Doe',
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Email',
                                controller: _emailController,
                                hint: 'example@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Mobile Number (Optional)',
                                controller: _mobileController,
                                hint: '+20 123 456 7890',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildPasswordField(
                                context: context,
                                label: 'Password',
                                controller: _passwordController,
                                isConfirm: false,
                              ),
                              const SizedBox(height: 16),
                              _buildPasswordField(
                                context: context,
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                isConfirm: true,
                              ),
                              const SizedBox(height: 24),
                              const Center(
                                child: Text(
                                  'By continuing, you agree to our',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Show terms of use
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Terms of Use',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      ' and ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Show privacy policy
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Sign Up Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF01579B),
                                      Color(0xFF0277BD),
                                      Color(0xFF0288D1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0D47A1)
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (_passwordController.text !=
                                                _confirmPasswordController
                                                    .text) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Passwords do not match'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            context.read<AuthBloc>().add(
                                                  SignUpSubmitted(
                                                    email: _emailController.text
                                                        .trim(),
                                                    password:
                                                        _passwordController
                                                            .text,
                                                    confirmPassword:
                                                        _confirmPasswordController
                                                            .text,
                                                    fullName: _fullNameController
                                                        .text
                                                        .trim(),
                                                    phone: _mobileController
                                                            .text
                                                            .trim()
                                                            .isEmpty
                                                        ? null
                                                        : _mobileController.text
                                                            .trim(),
                                                  ),
                                                );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account? ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF5A6C7D),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Log In',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF00BCD4),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6C7D),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF0F2F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required bool isConfirm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6C7D),
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => isConfirm
              ? previous.isConfirmPasswordVisible !=
                  current.isConfirmPasswordVisible
              : previous.isPasswordVisible != current.isPasswordVisible,
          builder: (context, state) {
            final isVisible = isConfirm
                ? state.isConfirmPasswordVisible
                : state.isPasswordVisible;

            return TextFormField(
              controller: controller,
              obscureText: !isVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                if (isConfirm && value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF5A6C7D),
                  ),
                  onPressed: () {
                    if (isConfirm) {
                      context.read<AuthBloc>().add(
                            const ConfirmPasswordVisibilityToggled(),
                          );
                    } else {
                      context.read<AuthBloc>().add(
                            const PasswordVisibilityToggled(),
                          );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
