import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../models/service_category.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';
import 'request_detail_screen.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final customer = repo.currentCustomer;

    return Scaffold(
      appBar: AppBar(title: const Text('My requests')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          if (customer == null) return const SizedBox.shrink();
          final requests = repo.requestsForCustomer(customer.id);
          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No requests yet',
              subtitle: 'Once you submit a request, you can track its progress here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final job = requests[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(job.category.icon),
                  title: Text(job.category.label),
                  subtitle: Text('${job.code} · ${DateFormat('d MMM, h:mm a').format(job.createdAt)}'),
                  trailing: StatusChip(status: job.status),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RequestDetailScreen(jobId: job.id)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
