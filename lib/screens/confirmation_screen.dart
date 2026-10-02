import 'package:flutter/material.dart';

import '../models/job_request.dart';
import '../models/service_category.dart';
import 'request_detail_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final JobRequest job;
  const ConfirmationScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: colors.primary, size: 72),
              const SizedBox(height: 20),
              Text('Request submitted!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                job.code,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                "We're matching you with a nearby ${job.category.label.toLowerCase()} professional.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => RequestDetailScreen(jobId: job.id)),
                    (route) => route.isFirst,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Track request'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
