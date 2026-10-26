import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case TaskStatus.pending:
        label = 'Chờ xử lý';
        color = AppColors.statusPending;
        break;
      case TaskStatus.inProgress:
        label = 'Đang làm';
        color = AppColors.statusInProgress;
        break;
      case TaskStatus.completed:
        label = 'Hoàn thành';
        color = AppColors.statusCompleted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
