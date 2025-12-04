import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/core/common/custom_button.dart';
import 'package:motelapp/core/common/custom_text_field.dart';
import 'package:motelapp/core/utils/ui_utils.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';
import 'package:motelapp/logic/cubits/auth/auth_state.dart';
import 'package:motelapp/presentation/screens/buttonNavicationBar/buttonNavicationBar.dart';
import 'package:motelapp/presentation/screens/auth/signup_screen.dart';
import 'package:motelapp/presentation/user_screens/userButtonNavicationBar/userButtonNavicationBar.dart';
import 'package:motelapp/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address (e.g., example@gmail.com)';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      print("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        // ========== SỬA LOGIC Ở ĐÂY ==========
        if (state.status == AuthStatus.authenticated) {
          // 1. Lấy vai trò từ state
          final String vaiTro = state.user?.vaitro ?? '';
          print('Đăng nhập thành công. Vai trò: $vaiTro');

          // 2. Điều hướng dựa trên vai trò
          if (vaiTro == 'ChuTro') {
            getIt<AppRouter>().pushAndRemoveUntil(const Buttonnavicationbar());
          } else if (vaiTro == 'NguoiThue') {
            getIt<AppRouter>().pushAndRemoveUntil(
              const UserButtonnavicationbar(),
            );
          } else {
            // Trường hợp vai trò không xác định
            UiUtils.showSnackBar(
              context,
              message: 'Vai trò không xác định. Vui lòng đăng nhập lại.',
            );
            getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
          }
        } else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackBar(context, message: state.error!);
        }
        // =======================================
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Welcome Back",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      focusNode: _emailFocus,
                      validator: _validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      focusNode: _passwordFocus,
                      validator: _validatePassword,
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      onPressed: handleSignIn,
                      text: "Login",
                      child:
                          state.status == AuthStatus.loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account?  ",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      getIt<AppRouter>().push(SignupScreen());
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
