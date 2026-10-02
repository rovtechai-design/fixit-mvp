import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../screens/welcome_screen.dart';

class ProfileMenu extends StatelessWidget {
  final String name;
  final String subtitle;

  const ProfileMenu({super.key, required this.name, required this.subtitle});

  Future<void> _goToWelcome(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text(
          'This clears every request, profile, and job on this device and reloads the starter demo data. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed == true) {
      await AppRepository.instance.resetDemoData();
      if (context.mounted) _goToWelcome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      icon: const Icon(Icons.account_circle),
      onSelected: (value) async {
        switch (value) {
          case 'switch':
            await AppRepository.instance.switchRole();
            if (context.mounted) _goToWelcome(context);
            break;
          case 'logout':
            await AppRepository.instance.logOut();
            if (context.mounted) _goToWelcome(context);
            break;
          case 'reset':
            await _confirmReset(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text('$name · $subtitle', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'switch', child: Text('Switch role')),
        const PopupMenuItem(value: 'logout', child: Text('Log out')),
        const PopupMenuItem(value: 'reset', child: Text('Reset demo data')),
      ],
    );
  }
}
