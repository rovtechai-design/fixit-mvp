import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../models/job_request.dart';
import '../models/service_category.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_tracker.dart';

class RequestDetailScreen extends StatelessWidget {
  final String jobId;
  const RequestDetailScreen({super.key, required this.jobId});

  Future<void> _cancel(BuildContext context, JobRequest job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text('You can only cancel while no provider has been assigned yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep request')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Cancel request')),
        ],
      ),
    );
    if (confirmed == true) {
      await AppRepository.instance.cancelJob(job.id, job.customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          final job = repo.getJobById(jobId);
          if (job == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(job.code, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    StatusChip(status: job.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(job.category.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                StatusTracker(status: job.status),
                const SizedBox(height: 24),
                _InfoCard(
                  title: 'Request details',
                  rows: {
                    'Description': job.description,
                    'Address': job.address,
                    'Preferred time': '${job.preferredDay.label}, ${job.preferredSlot.label}',
                    'Submitted': DateFormat('d MMM yyyy, h:mm a').format(job.createdAt),
                  },
                ),
                if (job.assignedProviderName != null) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Your service provider',
                    rows: {
                      'Name': job.assignedProviderName!,
                      'Phone': job.assignedProviderPhone ?? '-',
                    },
                  ),
                ],
                if (job.status == JobStatus.submitted) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _cancel(context, job),
                      child: const Text('Cancel request'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            for (final entry in rows.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 110, child: Text(entry.key, style: TextStyle(color: Theme.of(context).colorScheme.outline))),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
