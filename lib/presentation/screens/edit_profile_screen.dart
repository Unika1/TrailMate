import 'package:flutter/material.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/show_message.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController(text: 'TrailMate User');
  final emailController = TextEditingController(text: 'user@trailmate.com');
  final locationController = TextEditingController(text: 'Kathmandu, Nepal');

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 16),
          TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 24),
          AppButton(
            text: 'Save Changes',
            onPressed: () {
              showMessage(context, 'Profile updated successfully');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
