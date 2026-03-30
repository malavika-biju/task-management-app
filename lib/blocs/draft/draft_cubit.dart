import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftState {
  final String title;
  final String description;
  final DateTime? dueDate;
  final int? statusIndex;
  final int? blockedById;

  const DraftState({
    this.title = '',
    this.description = '',
    this.dueDate,
    this.statusIndex,
    this.blockedById,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'statusIndex': statusIndex,
    'blockedById': blockedById,
  };

  factory DraftState.fromJson(Map<String, dynamic> json) => DraftState(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    statusIndex: json['statusIndex'],
    blockedById: json['blockedById'],
  );
}

class DraftCubit extends Cubit<DraftState> {
  static const _draftKey = 'task_draft';
  final SharedPreferences _prefs;

  DraftCubit(this._prefs) : super(const DraftState()) {
    _loadDraft();
  }

  void _loadDraft() {
    final jsonStr = _prefs.getString(_draftKey);
    if (jsonStr != null) {
      try {
        emit(DraftState.fromJson(jsonDecode(jsonStr)));
      } catch (_) {}
    }
  }

  void updateDraft({
    String? title,
    String? description,
    DateTime? dueDate,
    int? statusIndex,
    int? blockedById,
  }) {
    final newState = DraftState(
      title: title ?? state.title,
      description: description ?? state.description,
      dueDate: dueDate ?? state.dueDate,
      statusIndex: statusIndex ?? state.statusIndex,
      blockedById: blockedById ?? state.blockedById,
    );
    emit(newState);
    _prefs.setString(_draftKey, jsonEncode(newState.toJson()));
  }

  void clearDraft() {
    emit(const DraftState());
    _prefs.remove(_draftKey);
  }
}
