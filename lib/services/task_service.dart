import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  static const String _boxName = 'tasks_box';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    await Hive.openBox<Task>(_boxName);
  }

  Future<List<Task>> getAllTasks() async {
    final box = Hive.box<Task>(_boxName);
    return box.values.toList();
  }

  Future<void> saveTask(Task task) async {
    // Simulate a 2-second network/processing delay (required by assignment)
    await Future.delayed(const Duration(seconds: 2));
    final box = Hive.box<Task>(_boxName);
    if (task.id == null) {
      // New task
      final id = await box.add(task);
      task.id = id;
      await task.save(); // Save with ID
    } else {
      // Update task
      await task.save();
    }
  }

  Future<void> deleteTask(int id) async {
    final box = Hive.box<Task>(_boxName);
    await box.delete(id);
  }

  Future<void> updateTaskStatus(int id, TaskStatus status) async {
    final box = Hive.box<Task>(_boxName);
    final task = box.get(id);
    if (task != null) {
      task.status = status;
      await task.save();
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    if (query.isEmpty) return getAllTasks();
    final tasks = await getAllTasks();
    return tasks.where((t) => t.title.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
