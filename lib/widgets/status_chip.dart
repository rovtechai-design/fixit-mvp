import 'package:flutter/material.dart';

import '../models/job_request.dart';

class StatusChip extends StatelessWidget {
  final JobStatus status;
  const StatusChip({super.key, required this.status});

  Color _color(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case JobStatus.submitted:
        return colors.secondary;
      case JobStatus.assigned:
        return colors.primary;
      case JobStatus.onTheWay:
        return colors.primary;
      case JobStatus.completed:
        return Colors.green.shade700;
      case JobStatus.cancelled:
        return colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
