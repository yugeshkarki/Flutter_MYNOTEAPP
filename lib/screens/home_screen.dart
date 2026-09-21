import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openForm(BuildContext context, [Note? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          Switch(
            value: isDark,
            onChanged: (v) => context.read<ThemeProvider>().setDark(v),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context, notes),
    );
  }

  Widget _buildBody(BuildContext context, NotesProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.notes.isEmpty) {
      return Center(child: Text(provider.error!));
    }
    if (provider.notes.isEmpty) {
      return const Center(child: Text('No notes yet. Tap + to add one.'));
    }

    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: provider.notes.length,
          itemBuilder: (context, i) {
            final note = provider.notes[i];
            final messenger = ScaffoldMessenger.of(context);
            final d = note.updatedAt;

            return Dismissible(
              key: ValueKey(note.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmDelete(context),
              onDismissed: (_) async {
                final ok = await context.read<NotesProvider>().delete(note);
                if (!ok) {
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Could not delete note')));
                }
              },
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: scheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete, color: scheme.onError),
              ),
              child: Card(
                child: ListTile(
                  title: Text(note.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(note.content,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text('${d.day}/${d.month}/${d.year}',
                      style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => _openForm(context, note),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
