import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../models/job_request.dart';
import '../models/service_category.dart';
import '../models/trade.dart';
import '../util/app_config.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_menu.dart';
import '../widgets/status_chip.dart';
import 'job_detail_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final provider = repo.currentProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [ProfileMenu(name: provider?.name ?? 'Guest', subtitle: provider?.trade.label ?? 'Provider')],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Available jobs'), Tab(text: 'My jobs')],
        ),
      ),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          if (provider == null) return const SizedBox.shrink();

          final available = repo.availableJobsForProvider(provider.trade);
          final myJobs = repo.myJobsForProvider(provider.id);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    _CountTile(label: 'Available', count: available.length),
                    const SizedBox(width: 8),
                    _CountTile(label: 'Active', count: repo.activeCountForProvider(provider.id)),
                    const SizedBox(width: 8),
                    _CountTile(label: 'Completed', count: repo.completedCountForProvider(provider.id)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AvailableJobsList(jobs: available),
                    _MyJobsList(jobs: myJobs, providerId: provider.id),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  final String label;
  final int count;
  const _CountTile({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: colors.outline)),
          ],
        ),
      ),
    );
  }
}

class _AvailableJobsList extends StatelessWidget {
  final List<JobRequest> jobs;
  const _AvailableJobsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt,
        title: 'No jobs waiting right now',
        subtitle: 'New requests in your trade will show up here as soon as customers submit them.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: CircleAvatar(child: Icon(job.category.icon)),
            title: Text(job.category.label),
            subtitle: Text(
              '${job.description}\n${job.area} · ${job.preferredDay.label}, ${job.preferredSlot.label} · posted ${_timeAgo(job.createdAt)}',
            ),
            isThreeLine: true,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id))),
          ),
        );
      },
    );
  }
}

class _MyJobsList extends StatelessWidget {
  final List<JobRequest> jobs;
  final String providerId;
  const _MyJobsList({required this.jobs, required this.providerId});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.work_outline,
        title: 'No jobs yet',
        subtitle: 'Jobs you accept will show up here so you can update their status.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(job.category.icon),
            title: Text('${job.customerName} · ${job.category.label}'),
            subtitle: Text('${job.customerPhone}\n${job.address}'),
            isThreeLine: true,
            trailing: StatusChip(status: job.status),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id))),
          ),
        );
      },
    );
  }
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return DateFormat('d MMM').format(time);
}
