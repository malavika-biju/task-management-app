import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/draft/draft_cubit.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.toDo;
  int? _blockedById;

  @override
  void initState() {
    super.initState();
    final draft = context.read<DraftCubit>().state;
    final task = widget.task;

    _titleController = TextEditingController(
      text: task?.title ?? (task == null ? draft.title : ''),
    );
    _descriptionController = TextEditingController(
      text: task?.description ?? (task == null ? draft.description : ''),
    );
    _dueDate = task?.dueDate ?? (task == null ? draft.dueDate : null);
    _status = task?.status ?? (task == null && draft.statusIndex != null 
        ? TaskStatus.values[draft.statusIndex!] 
        : TaskStatus.toDo);
    _blockedById = task?.blockedById ?? (task == null ? draft.blockedById : null);

    // Listen to changes to update draft (only for new tasks)
    if (task == null) {
      _titleController.addListener(_updateDraft);
      _descriptionController.addListener(_updateDraft);
    }
  }

  void _updateDraft() {
    context.read<DraftCubit>().updateDraft(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          statusIndex: _status.index,
          blockedById: _blockedById,
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    final tasks = context.read<TaskBloc>().state.tasks;
    final availableBlockers = tasks.where((t) => t.id != widget.task?.id).toList();

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (!state.isProcessing && state.status == TaskStatusState.success) {
          // Check if we were actually saving (isProcessing was true in previous state)
          // For simplicity in this demo, we'll just show success and let the user pop or auto-pop
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Task saved successfully!'), backgroundColor: Colors.green),
           );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(isEdit ? 'Edit Task' : 'New Task'),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF1F1F39)),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                _buildFieldLabel('TASK TITLE'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration('Design Web Dashboard', Icons.title),
                  validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('DESCRIPTION'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration('Details about the task...', Icons.description_outlined),
                  validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('DUE DATE'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _containerDecoration(),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFF8B5CF6)),
                                  const SizedBox(width: 12),
                                  Text(
                                    _dueDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_dueDate!),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('STATUS'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<TaskStatus>(
                            value: _status,
                            dropdownColor: Colors.white,
                            decoration: _inputDecoration('', null),
                            items: TaskStatus.values
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName)))
                                .toList(),
                            onChanged: (val) => setState(() => _status = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: state.isProcessing ? null : _save,
                  child: state.isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'Update Task' : 'Create Task', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.grey[400],
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal, fontSize: 16),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF8B5CF6), size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF8F7FF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF8F7FF),
      borderRadius: BorderRadius.circular(16),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (_formKey.currentState!.validate() && _dueDate != null) {
      final taskToSave = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate!,
        status: _status,
        blockedById: _blockedById,
      );

      if (widget.task != null) {
        taskToSave.id = widget.task!.id;
        context.read<TaskBloc>().add(UpdateTask(taskToSave));
      } else {
        context.read<TaskBloc>().add(AddTask(taskToSave));
        context.read<DraftCubit>().clearDraft();
      }

      // Auto-pop after a short delay
       Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
    } else if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a due date')));
    }
  }
}
