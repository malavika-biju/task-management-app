import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

// Events
abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  UpdateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int? id; // Hive IDs can be null before save
  DeleteTask(this.id);
  @override
  List<Object?> get props => [id];
}

class SearchTasks extends TaskEvent {
  final String query;
  SearchTasks(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterTasks extends TaskEvent {
  final TaskStatus? status;
  FilterTasks(this.status);
  @override
  List<Object?> get props => [status];
}

// State
enum TaskStatusState { initial, loading, success, failure }

class TaskState extends Equatable {
  final List<Task> tasks;
  final TaskStatusState status;
  final String? error;
  final String searchQuery;
  final TaskStatus? filterStatus;
  final bool isProcessing;

  const TaskState({
    this.tasks = const [],
    this.status = TaskStatusState.initial,
    this.error,
    this.searchQuery = '',
    this.filterStatus,
    this.isProcessing = false,
  });

  TaskState copyWith({
    List<Task>? tasks,
    TaskStatusState? status,
    String? error,
    String? searchQuery,
    TaskStatus? filterStatus,
    bool? isProcessing,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [tasks, status, error, searchQuery, filterStatus, isProcessing];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;

  TaskBloc(this._taskService) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<SearchTasks>(_onSearchTasks);
    on<FilterTasks>(_onFilterTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatusState.loading));
    try {
      final tasks = await _taskService.getAllTasks();
      emit(state.copyWith(tasks: tasks, status: TaskStatusState.success));
    } catch (e) {
      emit(state.copyWith(status: TaskStatusState.failure, error: e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatusState.loading, isProcessing: true));
    try {
      await _taskService.saveTask(event.task);
      final tasks = await _taskService.getAllTasks();
      emit(state.copyWith(tasks: tasks, status: TaskStatusState.success, isProcessing: false));
    } catch (e) {
      emit(state.copyWith(status: TaskStatusState.failure, error: e.toString(), isProcessing: false));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatusState.loading, isProcessing: true));
    try {
      await _taskService.saveTask(event.task);
      final tasks = await _taskService.getAllTasks();
      emit(state.copyWith(tasks: tasks, status: TaskStatusState.success, isProcessing: false));
    } catch (e) {
      emit(state.copyWith(status: TaskStatusState.failure, error: e.toString(), isProcessing: false));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (event.id == null) return;
    try {
      await _taskService.deleteTask(event.id!);
      final tasks = await _taskService.getAllTasks();
      emit(state.copyWith(tasks: tasks, status: TaskStatusState.success));
    } catch (e) {
      emit(state.copyWith(status: TaskStatusState.failure, error: e.toString()));
    }
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    emit(state.copyWith(filterStatus: event.status));
  }

  List<Task> get filteredTasks {
    return state.tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(state.searchQuery.toLowerCase());
      final matchesFilter = state.filterStatus == null || task.status == state.filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }
}
