class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Nombre del archivo .txt en disco
  String get fileName => 'note_$id.txt';

  /// Serializa la nota en formato texto plano para guardar en .txt
  String toFileContent() {
    return '${title}\n---\n${content}\n---\n${createdAt.toIso8601String()}\n${updatedAt.toIso8601String()}';
  }

  /// Crea una Note desde el contenido de un archivo .txt
  factory Note.fromFileContent(String id, String raw) {
    final parts = raw.split('\n---\n');
    final title = parts.isNotEmpty ? parts[0].trim() : 'Sin título';
    final content = parts.length > 1 ? parts[1].trim() : '';
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();

    if (parts.length > 2) {
      final dates = parts[2].trim().split('\n');
      if (dates.isNotEmpty) createdAt = DateTime.tryParse(dates[0]) ?? createdAt;
      if (dates.length > 1) updatedAt = DateTime.tryParse(dates[1]) ?? updatedAt;
    }

    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
