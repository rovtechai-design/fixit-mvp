import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../models/service_category.dart';
import '../util/app_config.dart';
import '../widgets/profile_menu.dart';
import 'my_requests_screen.dart';
import 'new_request_screen.dart';

const _categoryTiles = [
  ServiceCategory.plumbing,
  ServiceCategory.electrical,
  ServiceCategory.acService,
  ServiceCategory.homeCleaning,
  ServiceCategory.terraceOutdoorCleaning,
  ServiceCategory.gardening,
  ServiceCategory.tailoringAlterations,
  ServiceCategory.notSure,
];

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = AppRepository.instance.currentCustomer;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [ProfileMenu(name: customer?.name ?? 'Guest', subtitle: 'Customer')],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _categoryTiles.length,
                itemBuilder: (context, index) {
                  final category = _categoryTiles[index];
                  return _CategoryTile(
                    category: category,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => NewRequestScreen(category: category)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('My requests'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyRequestsScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 36, color: colors.onPrimaryContainer),
              const SizedBox(height: 10),
              Text(
                category.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, color: colors.onPrimaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
