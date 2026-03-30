import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task/task_bloc.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final bool isEmbedded;

  const TaskListScreen({super.key, this.isEmbedded = false});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        if (state.status == TaskStatusState.loading && state.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
        }

        final filteredTasks = context.read<TaskBloc>().filteredTasks;

        if (filteredTasks.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TaskBloc>().add(LoadTasks());
          },
          child: ListView.builder(
            // Key fix: If embedded, we want it to take full space and scroll independently
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              final isBlocked = _isTaskBlocked(task, state.tasks);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  task: task,
                  isBlocked: isBlocked,
                  searchQuery: state.searchQuery,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
                  ),
                  onDelete: () => context.read<TaskBloc>().add(DeleteTask(task.id)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isTaskBlocked(Task task, List<Task> allTasks) {
    if (task.blockedById == null) return false;
    return allTasks.any((t) => t.id == task.blockedById && t.status != TaskStatus.done);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_add, size: 48, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click the button above to create your first task',
            style: TextStyle(color: Color(0xFF92929D), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
