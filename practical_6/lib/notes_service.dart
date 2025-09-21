import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.category = '',
    required this.createdAt,
    required this.modifiedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'modifiedAt': modifiedAt.millisecondsSinceEpoch,
    'isPinned': isPinned,
  };

  static Note fromJson(Map<String, dynamic> j) => Note(
    id: j['id'] ?? '',
    title: j['title'] ?? '',
    body: j['body'] ?? '',
    category: j['category'] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      j['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    ),
    modifiedAt: DateTime.fromMillisecondsSinceEpoch(
      j['modifiedAt'] ?? DateTime.now().millisecondsSinceEpoch,
    ),
    isPinned: j['isPinned'] ?? false,
  );

  Note copyWith({
    String? title,
    String? body,
    String? category,
    DateTime? modifiedAt,
    bool? isPinned,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class NotesService {
  static const _key = 'practical6_notes';
  static const _statsKey = 'note_stats';

  Future<List<Note>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];

      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Return empty list if data is corrupted
      return [];
    }
  }

  Future<void> save(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(notes.map((n) => n.toJson()).toList());
      await prefs.setString(_key, raw);
      await _updateStats(notes);
    } catch (e) {
      throw Exception('Failed to save notes: $e');
    }
  }

  Future<void> _updateStats(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = {
        'total_notes': notes.length,
        'categories': _getUniqueCategories(notes),
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        'pinned_count': notes.where((n) => n.isPinned).length,
      };
      await prefs.setString(_statsKey, json.encode(stats));
    } catch (e) {
      // Stats update failure shouldn't break the app
    }
  }

  List<String> _getUniqueCategories(List<Note> notes) {
    final categories = notes
        .where((n) => n.category.isNotEmpty)
        .map((n) => n.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<Note> create(String title, String body, {String category = ''}) async {
    try {
      final notes = await load();
      final now = DateTime.now();
      final id = const Uuid().v4();

      final note = Note(
        id: id,
        title: title.trim(),
        body: body.trim(),
        category: category.trim(),
        createdAt: now,
        modifiedAt: now,
      );

      notes.add(note);
      await save(notes);
      return note;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      final notes = await load();
      final originalLength = notes.length;
      notes.removeWhere((n) => n.id == id);

      if (notes.length == originalLength) {
        throw Exception('Note not found');
      }

      await save(notes);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<void> update(Note note) async {
    try {
      final notes = await load();
      final idx = notes.indexWhere((n) => n.id == note.id);

      if (idx < 0) {
        throw Exception('Note not found');
      }

      notes[idx] = note.copyWith(modifiedAt: DateTime.now());
      await save(notes);
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<List<Note>> search(String query) async {
    try {
      if (query.isEmpty) return await load();

      final notes = await load();
      final lowercaseQuery = query.toLowerCase();

      return notes.where((note) {
        return note.title.toLowerCase().contains(lowercaseQuery) ||
            note.body.toLowerCase().contains(lowercaseQuery) ||
            note.category.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Note>> getByCategory(String category) async {
    try {
      final notes = await load();
      return notes.where((n) => n.category == category).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final notes = await load();
      return _getUniqueCategories(notes);
    } catch (e) {
      return [];
    }
  }

  Future<void> togglePin(String id) async {
    try {
      final notes = await load();
      final idx = notes.indexWhere((n) => n.id == id);

      if (idx < 0) {
        throw Exception('Note not found');
      }

      notes[idx] = notes[idx].copyWith(isPinned: !notes[idx].isPinned);
      await save(notes);
    } catch (e) {
      throw Exception('Failed to toggle pin: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_statsKey);

      if (raw == null || raw.isEmpty) {
        return {
          'total_notes': 0,
          'categories': <String>[],
          'last_updated': 0,
          'pinned_count': 0,
        };
      }

      return json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      return {
        'total_notes': 0,
        'categories': <String>[],
        'last_updated': 0,
        'pinned_count': 0,
      };
    }
  }

  Future<void> backup() async {
    try {
      final notes = await load();
      final prefs = await SharedPreferences.getInstance();

      final backup = {
        'notes': notes.map((n) => n.toJson()).toList(),
        'backup_date': DateTime.now().millisecondsSinceEpoch,
        'version': '1.0',
      };

      await prefs.setString('notes_backup', json.encode(backup));
    } catch (e) {
      throw Exception('Failed to backup notes: $e');
    }
  }

  Future<bool> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('notes_backup');

      if (raw == null || raw.isEmpty) {
        return false;
      }

      final backup = json.decode(raw) as Map<String, dynamic>;
      final notesList = backup['notes'] as List<dynamic>;
      final notes = notesList
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();

      await save(notes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
