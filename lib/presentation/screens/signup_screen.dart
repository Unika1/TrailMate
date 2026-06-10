import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/show_message.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    final nameErr = Validators.required(name, 'Full name');
    final emailErr = Validators.email(email);
    final passErr = Validators.password(password);
    final confirmErr =
        password != confirm ? 'Passwords do not match' : null;

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });
    if (nameErr != null ||
        emailErr != null ||
        passErr != null ||
        confirmErr != null) {
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(authProvider).signup(name, email, password);
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
            title: 'Sign Up',
            subtitle: 'Start your Adventure today.',
            imageAsset: 'assets/images/auth_signup.jpg',
            trekName: 'Everest Base Camp',
            dotCount: 4,
            activeDot: 0,
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
                  controller: nameController,
                  hint: 'Enter your full name',
                  textCapitalization: TextCapitalization.words,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
                const SizedBox(height: 14),
                AuthField(
                  controller: emailController,
                  hint: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),
                const SizedBox(height: 14),
                AuthField(
                  controller: passwordController,
                  hint: 'Create a password',
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
                const SizedBox(height: 14),
                AuthField(
                  controller: confirmPasswordController,
                  hint: 'Re-enter password',
                  obscure: _obscureConfirm,
                  errorText: _confirmError,
                  onChanged: (_) {
                    if (_confirmError != null) {
                      setState(() => _confirmError = null);
                    }
                  },
                  suffix: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedText),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 22),
                AuthButton(
                  text: 'Sign Up',
                  loading: _loading,
                  onPressed: _signup,
                ),
                const OrDivider(),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen())),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Sign In',
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
