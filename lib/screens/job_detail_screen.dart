import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../models/job_request.dart';
import '../models/service_category.dart';
import '../util/photo_preview.dart';
import '../widgets/status_chip.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  Future<void> _accept(BuildContext context, JobRequest job) async {
    final provider = AppRepository.instance.currentProvider;
    if (provider == null) return;
    final success = await AppRepository.instance.acceptJob(job.id, provider);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job accepted')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Another provider already accepted this job')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _markOnTheWay(BuildContext context, JobRequest job) async {
    final provider = AppRepository.instance.currentProvider;
    if (provider == null) return;
    await AppRepository.instance.markOnTheWay(job.id, provider.id);
  }

  Future<void> _markCompleted(BuildContext context, JobRequest job) async {
    final provider = AppRepository.instance.currentProvider;
    if (provider == null) return;
    await AppRepository.instance.markCompleted(job.id, provider.id);
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final provider = repo.currentProvider;

    return Scaffold(
      appBar: AppBar(title: const Text('Job details')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          final job = repo.getJobById(jobId);
          if (job == null || provider == null) return const SizedBox.shrink();

          final isMine = job.assignedProviderId == provider.id;
          final isAvailable = job.status == JobStatus.submitted;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(job.category.label, style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    StatusChip(status: job.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(job.code, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                const SizedBox(height: 16),
                if (job.photoPath != null && !kIsWeb) ...[
                  buildPhotoPreview(job.photoPath!),
                  const SizedBox(height: 16),
                ],
                Text(job.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                _row(context, 'Preferred time', '${job.preferredDay.label}, ${job.preferredSlot.label}'),
                _row(context, 'Posted', DateFormat('d MMM, h:mm a').format(job.createdAt)),
                if (isAvailable) _row(context, 'Area', job.area),
                if (!isAvailable) ...[
                  _row(context, 'Customer', job.customerName),
                  _row(context, 'Phone', job.customerPhone),
                  _row(context, 'Address', job.address),
                ],
                const SizedBox(height: 28),
                if (isAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _accept(context, job),
                      child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Accept job')),
                    ),
                  )
                else if (isMine && job.status == JobStatus.assigned)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _markOnTheWay(context, job),
                      child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('On the way')),
                    ),
                  )
                else if (isMine && job.status == JobStatus.onTheWay)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _markCompleted(context, job),
                      child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Mark completed')),
                    ),
                  )
                else if (isMine && job.status == JobStatus.completed)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Job completed'),
                      ],
                    ),
                  )
                else
                  Text(
                    'This job was taken by another provider.',
                    style: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.outline))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
