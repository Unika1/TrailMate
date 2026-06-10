import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999)),
                  child: const Text('Welcome to TrailMate',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Plan Everest Base Camp and beyond with clean, simple trekking guidance.',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: 12),
              const Text(
                'Browse treks, compare filters, save routes, and keep contacts in one calm interface.',
                style: TextStyle(
                    color: AppColors.textGrey, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: const [
                    _FeatureCard(
                        icon: Icons.terrain,
                        title: 'Everest focus',
                        subtitle: 'EBC and nearby treks'),
                    _FeatureCard(
                        icon: Icons.filter_alt,
                        title: 'Smart filters',
                        subtitle: 'Region, duration, difficulty'),
                    _FeatureCard(
                        icon: Icons.bookmark,
                        title: 'Save routes',
                        subtitle: 'Keep treks you love'),
                    _FeatureCard(
                        icon: Icons.comment,
                        title: 'Comments',
                        subtitle: 'Share trek feedback'),
                  ],
                ),
              ),
              AppButton(
                text: 'Continue to Login',
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textGrey, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
