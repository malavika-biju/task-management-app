import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_list_screen.dart';
import 'task_form_screen.dart';
import '../models/task_model.dart';
import '../blocs/task/task_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      body: Row(
        children: [
          // 1. Main Workspace (Expanded to take more space)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 32),
                  _buildWelcomeCard(context),
                  const SizedBox(height: 40),
                  _buildTaskHeader(context),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: TaskListScreen(isEmbedded: true),
                  ),
                ],
              ),
            ),
          ),

          // 2. Quick Actions Panel (Right Sidebar)
          _buildRightSidebar(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Workspace',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D)),
            ),
            Text('Manage your daily tasks efficiently',
                style: TextStyle(color: Color(0xFF92929D), fontSize: 14)),
          ],
        ),
        Container(
          height: 48,
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F1F5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF92929D), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) =>
                      context.read<TaskBloc>().add(SearchTasks(val)),
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(color: Color(0xFFB5B5BE)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                final pendingCount = state.tasks
                    .where((t) => t.status != TaskStatus.done)
                    .length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pendingCount == 0
                          ? 'All caught up! You have no pending tasks.'
                          : 'You have $pendingCount tasks to complete today.\nStay productive and focused!',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Add Task',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Tasks',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D)),
        ),
        TextButton.icon(
          onPressed: () => context.read<TaskBloc>().add(LoadTasks()),
          icon: const Icon(Icons.sync, size: 16),
          label: const Text('Refresh',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
        ),
      ],
    );
  }

  Widget _buildRightSidebar(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFF3F2FF),
                child: Icon(Icons.person_outline, color: Color(0xFF8B5CF6)),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Workspace',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Level 1 Member',
                      style: TextStyle(color: Color(0xFF92929D), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text('Calendar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildMiniCalendar(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF8B5CF6)),
                SizedBox(height: 12),
                Text(
                  'Tip: Break large tasks into smaller ones to manage them better.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF92929D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Text(d,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFD1D1E0),
                      fontWeight: FontWeight.bold)))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [24, 25, 26, 27, 28, 29, 30]
              .map((d) => Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    decoration: d == 25
                        ? const BoxDecoration(
                            color: Color(0xFF8B5CF6), shape: BoxShape.circle)
                        : null,
                    child: Text(
                      '$d',
                      style: TextStyle(
                        fontSize: 12,
                        color: d == 25 ? Colors.white : const Color(0xFF1E1E2D),
                        fontWeight:
                            d == 25 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
