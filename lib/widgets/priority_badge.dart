import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (priority) {
      case TaskPriority.low:
        label = 'Thấp';
        color = AppColors.priorityLow;
        break;
      case TaskPriority.medium:
        label = 'Trung bình';
        color = AppColors.priorityMedium;
        break;
      case TaskPriority.high:
        label = 'Cao';
        color = AppColors.priorityHigh;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
