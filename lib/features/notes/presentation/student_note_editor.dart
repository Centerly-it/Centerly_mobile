import 'package:flutter/material.dart';
import '../../../core/errors/backend_failure.dart';
import '../data/student_note_repository.dart';
import '../domain/student_note.dart';

class StudentNoteEditor extends ChangeNotifier {
  StudentNoteEditor(this.repository, this.studentId);
  final StudentNoteRepository repository;
  final String studentId;
  final text = TextEditingController();
  StudentNote? saved;
  bool busy = false, failed = false, mustReload = false, _disposed = false;
  String? error;
  bool get dirty => saved != null && text.text != saved!.content;
  void changed() => _emit();
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (busy) return;
    busy = true;
    error = null;
    _emit();
    try {
      final note = await repository.load(studentId);
      if (_disposed) return;
      saved = note;
      text.text = note.content;
      mustReload = false;
      failed = false;
    } catch (e) {
      failed = true;
      error = e is BackendFailure ? e.code : 'SERVICE_UNAVAILABLE';
      mustReload = saved != null;
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<void> save() async {
    if (busy || saved == null || mustReload) return;
    busy = true;
    error = null;
    _emit();
    try {
      await repository.save(studentId, text.text, saved!.version);
      final note = await repository.load(studentId);
      if (_disposed) return;
      saved = note;
      text.text = note.content;
    } catch (e) {
      error = e is BackendFailure ? e.code : 'SERVICE_UNAVAILABLE';
      mustReload = true;
    } finally {
      busy = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    text.dispose();
    super.dispose();
  }
}
