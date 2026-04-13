import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesFolder = 'notas';

  // ─── Directorio base de notas ─────────────────────────────────────────────

  Future<Directory> get _notesDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/$_notesFolder');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir;
  }

  // ─── Leer todas las notas ─────────────────────────────────────────────────

  Future<List<Note>> loadAllNotes() async {
    try {
      final dir = await _notesDirectory;
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.txt'))
          .toList();

      final notes = <Note>[];
      for (final file in files) {
        final id = _extractId(file.path);
        if (id != null) {
          final content = await file.readAsString();
          notes.add(Note.fromFileContent(id, content));
        }
      }

      // Ordenar por última modificación (más reciente primero)
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    } catch (_) {
      return [];
    }
  }

  // ─── Guardar / actualizar nota ────────────────────────────────────────────

  Future<bool> saveNote(Note note) async {
    try {
      final dir = await _notesDirectory;
      final file = File('${dir.path}/${note.fileName}');
      await file.writeAsString(note.toFileContent());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Eliminar nota ────────────────────────────────────────────────────────

  Future<bool> deleteNote(Note note) async {
    try {
      final dir = await _notesDirectory;
      final file = File('${dir.path}/${note.fileName}');
      if (await file.exists()) await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Exportar nota (copia en Documentos raíz) ────────────────────────────

  Future<String?> exportNote(Note note) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final safeName = note.title
          .replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]'), '')
          .trim()
          .replaceAll(' ', '_');
      final exportPath = '${appDir.path}/${safeName}_export.txt';
      final file = File(exportPath);
      await file.writeAsString(note.toFileContent());
      return exportPath;
    } catch (_) {
      return null;
    }
  }

  // ─── Estadísticas ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    final notes = await loadAllNotes();
    final totalWords = notes.fold<int>(
      0,
      (sum, n) => sum + n.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    );
    return {
      'totalNotes': notes.length,
      'totalWords': totalWords,
    };
  }

  // ─── Utilidades ───────────────────────────────────────────────────────────

  String? _extractId(String path) {
    final match = RegExp(r'note_(.+)\.txt$').firstMatch(path);
    return match?.group(1);
  }

  String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
