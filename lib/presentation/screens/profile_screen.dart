import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primarySoft,
              child: Text(
                auth.userName.isNotEmpty
                    ? auth.userName[0].toUpperCase()
                    : 'T',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(auth.userName,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          if (user != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(user.email,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 14)),
            ),
          ],
          const SizedBox(height: 28),
          // Account section
          const _SectionHeader('Account'),
          _ProfileTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const _EditProfileDialog(),
            ),
          ),
          const _ProfileTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
          ),
          const _ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Preferences',
          ),
          const SizedBox(height: 16),
          const _SectionHeader('About'),
          _ProfileTile(
            icon: Icons.help_outline,
            title: 'Help & How it works',
            onTap: () => _showHelp(context),
          ),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'About TrailMate',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'TrailMate',
              applicationVersion: 'v1.0.0',
              applicationIcon:
                  const Icon(Icons.hiking, color: AppColors.brand),
              children: const [
                SizedBox(height: 8),
                Text(
                    'TrailMate helps trekkers plan Nepal routes with itineraries, '
                    'cost estimates, permits, contacts, and saved routes.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Logout
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(239, 68, 68, 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color.fromRGBO(239, 68, 68, 0.2)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.danger, fontWeight: FontWeight.w700)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                        'Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout',
                              style:
                                  TextStyle(color: AppColors.danger))),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authProvider).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('TrailMate v1.0.0',
                style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

void _showHelp(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Center(
            child: SizedBox(
              width: 40,
              child: Divider(thickness: 4, color: AppColors.border),
            ),
          ),
          SizedBox(height: 12),
          Text('How TrailMate works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 16),
          _HelpItem(
              icon: Icons.search,
              text: 'Browse and search treks, then filter by region, '
                  'duration, or difficulty.'),
          _HelpItem(
              icon: Icons.tab,
              text: 'Open a trek to see its Overview, Itinerary, Cost, '
                  'and Contacts.'),
          _HelpItem(
              icon: Icons.bookmark_border,
              text: 'Tap the bookmark to save a route — find it later in '
                  'the Saved tab.'),
          _HelpItem(
              icon: Icons.comment_outlined,
              text: 'Share your experience and a photo in Trip Comments.'),
        ],
      ),
    ),
  );
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text,
                  style: const TextStyle(fontSize: 13.5, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: .8)),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textGrey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.mutedText),
        onTap: onTap,
      ),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog();

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: ref.read(authProvider).userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Display Name'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Save')),
      ],
    );
  }
}
