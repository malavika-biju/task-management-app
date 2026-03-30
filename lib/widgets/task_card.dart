import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    required this.searchQuery,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isBlocked ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F1F5)),
        ),
        child: ListTile(
          onTap: isBlocked ? null : onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Icon(
            task.status == TaskStatus.done ? Icons.check_circle : Icons.circle_outlined,
            color: task.status == TaskStatus.done ? const Color(0xFF8B5CF6) : const Color(0xFFD1D1E0),
            size: 28,
          ),
          title: _buildHighlightedTitle(task.title, searchQuery),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (isBlocked) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.lock_clock, size: 12, color: Colors.amber),
                  const SizedBox(width: 4),
                  const Text('Blocked', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                ]
              ],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEB5757), size: 20),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle(String title, String query) {
    final isDone = task.status == TaskStatus.done;
    if (query.isEmpty) {
      return Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF1E1E2D),
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      );
    }
    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int index;
    while ((index = lowerTitle.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: title.substring(start, index),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF1E1E2D),
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ));
      }
      spans.add(TextSpan(
        text: title.substring(index, index + query.length),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: const Color(0xFF8B5CF6),
          backgroundColor: const Color(0xFFEDE9FE),
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ));
      start = index + query.length;
    }
    if (start < title.length) {
      spans.add(TextSpan(
        text: title.substring(start),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF1E1E2D),
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
    return '${date.day}/${date.month}/${date.year}';
  }
}