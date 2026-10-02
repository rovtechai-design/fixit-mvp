import 'package:flutter/material.dart';

import '../models/job_request.dart';

class StatusTracker extends StatelessWidget {
  final JobStatus status;
  const StatusTracker({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (status == JobStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text('This request was cancelled.', style: TextStyle(color: colors.onErrorContainer)),
            ),
          ],
        ),
      );
    }

    final currentIndex = trackerSteps.indexOf(status);

    return Column(
      children: [
        for (var i = 0; i < trackerSteps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    i <= currentIndex ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: i <= currentIndex ? colors.primary : colors.outlineVariant,
                  ),
                  if (i != trackerSteps.length - 1)
                    Container(
                      width: 2,
                      height: 32,
                      color: i < currentIndex ? colors.primary : colors.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  trackerSteps[i].label,
                  style: TextStyle(
                    fontWeight: i == currentIndex ? FontWeight.w700 : FontWeight.w400,
                    color: i <= currentIndex ? colors.onSurface : colors.outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
