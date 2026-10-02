import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../models/trade.dart';
import '../util/app_config.dart';
import 'customer_home_screen.dart';
import 'provider_home_screen.dart';
import 'signin_customer_screen.dart';
import 'signin_provider_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: repo,
          builder: (context, _) {
            final lastCustomer = repo.lastCustomer;
            final lastProvider = repo.lastProvider;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Icon(Icons.home_repair_service, size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    AppConfig.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.tagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                  const Spacer(flex: 3),
                  if (lastCustomer != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.person),
                        label: Text('Continue as ${lastCustomer.name} (Customer)'),
                        onPressed: () async {
                          await repo.continueAsCustomer();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                  if (lastProvider != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.badge),
                        label: Text('Continue as ${lastProvider.name} (${lastProvider.trade.label})'),
                        onPressed: () async {
                          await repo.continueAsProvider();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInCustomerScreen()),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('I need help'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInProviderScreen()),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text("I'm a service provider"),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
