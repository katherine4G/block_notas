import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/stats_banner.dart';
import 'note_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storage = StorageService();
  List<Note> _notes = [];
  List<Note> _filtered = [];
  bool _loading = true;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Cargar todas las notas desde disco ───────────────────────────────────

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    final notes = await _storage.loadAllNotes();
    setState(() {
      _notes = notes;
      _filtered = _applyFilter(notes);
      _loading = false;
    });
  }

  List<Note> _applyFilter(List<Note> notes) {
    if (_query.isEmpty) return notes;
    final q = _query.toLowerCase();
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList();
  }

  void _onSearch(String q) {
    setState(() {
      _query = q;
      _filtered = _applyFilter(_notes);
    });
  }

  // ─── Navegación al editor ─────────────────────────────────────────────────

  Future<void> _openEditor({Note? note}) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(
          note: note,
          storageService: _storage,
        ),
      ),
    );
    if (result != null) await _loadNotes();
  }

  // ─── Eliminar nota ────────────────────────────────────────────────────────

  Future<void> _deleteNote(Note note) async {
    await _storage.deleteNote(note);
    await _loadNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.title}" eliminada'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Exportar nota ────────────────────────────────────────────────────────

  Future<void> _exportNote(Note note) async {
    final path = await _storage.exportNote(note);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(path != null
            ? '✓ Exportado:\n$path'
            : 'Error al exportar'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Notas',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        '${_notes.length} nota${_notes.length == 1 ? '' : 's'} · almacenadas offline',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Recargar',
                    onPressed: _loadNotes,
                  ),
                ],
              ),
            ),

            // ── Estadísticas ──────────────────────────────────────────────
            if (_notes.isNotEmpty)
              StatsBanner(
                totalNotes: _notes.length,
                totalWords: _notes.fold(
                  0,
                  (sum, n) => sum +
                      n.content
                          .split(RegExp(r'\s+'))
                          .where((w) => w.isNotEmpty)
                          .length,
                ),
              ),

            // ── Búsqueda ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SearchBar(
                controller: _searchCtrl,
                hintText: 'Buscar notas…',
                onChanged: _onSearch,
                leading: const Icon(Icons.search),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearch('');
                      },
                    ),
                ],
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.4)),
                  ),
                ),
              ),
            ),

            // ── Lista de notas ────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? EmptyState(
                          icon: _query.isEmpty
                              ? Icons.edit_note_outlined
                              : Icons.search_off_outlined,
                          message: _query.isEmpty
                              ? 'No hay notas todavía'
                              : 'Sin resultados para "$_query"',
                          subtitle: _query.isEmpty
                              ? 'Toca el botón + para crear tu primera nota'
                              : null,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotes,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final note = _filtered[i];
                              return NoteCard(
                                note: note,
                                onTap: () => _openEditor(note: note),
                                onDelete: () => _deleteNote(note),
                                onExport: () => _exportNote(note),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
      ),
    );
  }
}
