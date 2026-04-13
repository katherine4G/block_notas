import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note; // null = nueva nota
  final StorageService storageService;

  const NoteEditorPage({
    super.key,
    this.note,
    required this.storageService,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _hasChanges = false;
  bool _isSaving = false;

  bool get _isNew => widget.note == null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _titleCtrl.addListener(_markChanged);
    _contentCtrl.addListener(_markChanged);
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final title = _titleCtrl.text.trim().isEmpty
        ? 'Sin título'
        : _titleCtrl.text.trim();
    final content = _contentCtrl.text;

    setState(() => _isSaving = true);

    final Note note;
    if (_isNew) {
      note = Note(
        id: widget.storageService.generateId(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      note = widget.note!.copyWith(title: title, content: content);
    }

    final ok = await widget.storageService.saveNote(note);
    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Nota guardada'),
          ]),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, note);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar')),
      );
    }
  }

  // ─── Exportar ─────────────────────────────────────────────────────────────

  Future<void> _export() async {
    if (widget.note == null) return;
    final path = await widget.storageService.exportNote(widget.note!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(path != null
            ? 'Exportado en:\n$path'
            : 'Error al exportar'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── Confirmar descarte ───────────────────────────────────────────────────

  Future<bool> _onPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Descartar cambios?'),
        content: const Text('Los cambios no guardados se perderán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  int get _wordCount => _contentCtrl.text
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .length;

  int get _charCount => _contentCtrl.text.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final should = await _onPop();
          if (should && context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          title: Text(
            _isNew ? 'Nueva nota' : 'Editar nota',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            if (!_isNew)
              IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                tooltip: 'Exportar .txt',
                onPressed: _export,
              ),
            const SizedBox(width: 4),
            FilledButton.icon(
              onPressed: _hasChanges && !_isSaving ? _save : null,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Guardar'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            // Campo título
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _titleCtrl,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Título de la nota',
                  hintStyle: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    fontWeight: FontWeight.w800,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            // Separador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
            ),

            // Campo contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: TextField(
                  controller: _contentCtrl,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                  decoration: InputDecoration(
                    hintText: 'Empieza a escribir tu nota aquí…',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),

            // Barra inferior con estadísticas
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _InfoChip(
                    icon: Icons.text_fields,
                    label: '$_wordCount palabras',
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.onetwothree,
                    label: '$_charCount caracteres',
                  ),
                  if (widget.note != null) ...[
                    const Spacer(),
                    Text(
                      'Guardado: ${_formatDate(widget.note!.updatedAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
