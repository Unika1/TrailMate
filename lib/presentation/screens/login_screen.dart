import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/show_message.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../providers/trek_provider.dart';
import '../widgets/auth_header.dart';
import 'main_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailErr = Validators.email(email);
    final passErr = Validators.password(password);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    if (emailErr != null || passErr != null) return;

    setState(() => _loading = true);

    try {
      await ref.read(authProvider).login(email, password);
      await ref.read(trekProvider).loadSavedRoutes();
    } catch (e) {
      if (mounted) {
        showMessage(context, e.toString().replaceAll('Exception: ', ''));
      }
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = false);
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AuthHeader(
            title: 'Sign In',
            subtitle: 'Start your Adventure today.',
            imageAsset: 'assets/images/auth_signin.jpg',
            trekName: 'Shey Phoksundo Lake Trek',
            dotCount: 4,
            activeDot: 1,
          ),
          // White form sheet (pulled up to overlap the teal header)
          Container(
            transform: Matrix4.translationValues(0, -24, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              children: [
                AuthField(
                  controller: emailController,
                  hint: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                ),
                const SizedBox(height: 14),
                AuthField(
                  controller: passwordController,
                  hint: 'Enter your password',
                  obscure: _obscure,
                  errorText: _passwordError,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  suffix: IconButton(
                    icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedText),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => showMessage(
                        context, 'Password reset link sent (demo)'),
                    child: const Text('Forgot password?',
                        style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 16),
                AuthButton(
                  text: 'Sign In',
                  loading: _loading,
                  onPressed: _login,
                ),
                const OrDivider(),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignupScreen())),
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account?  ",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
