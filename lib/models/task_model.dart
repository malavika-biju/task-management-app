import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late DateTime dueDate;

  @HiveField(4)
  late TaskStatus status;

  @HiveField(5)
  int? blockedById;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedById,
  }) {
    final t = Task(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById ?? this.blockedById,
    );
    t.id = id;
    return t;
  }
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  toDo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.toDo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}
