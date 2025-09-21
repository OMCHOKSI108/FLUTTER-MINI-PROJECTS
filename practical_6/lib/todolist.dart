import 'package:flutter/material.dart';
import 'notes_service.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final NotesService _service = NotesService();
  final TextEditingController _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  bool _loading = true;
  String _sortBy = 'modified'; // 'modified', 'created', 'title'
  bool _showPinnedFirst = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterNotes();
  }

  Future<void> _load() async {
    try {
      final list = await _service.load();
      final categories = await _service.getCategories();

      setState(() {
        _notes = list;
        _categories = categories;
        _loading = false;
      });
      _filterNotes();
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _showError('Failed to load notes: $e');
    }
  }

  void _filterNotes() {
    List<Note> filtered = List.from(_notes);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.body.toLowerCase().contains(query) ||
            note.category.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((note) => note.category == _selectedCategory)
          .toList();
    }

    // Sort notes
    filtered.sort((a, b) {
      // Pinned notes first if enabled
      if (_showPinnedFirst && a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      switch (_sortBy) {
        case 'created':
          return b.createdAt.compareTo(a.createdAt);
        case 'title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'modified':
        default:
          return b.modifiedAt.compareTo(a.modifiedAt);
      }
    });

    setState(() {
      _filteredNotes = filtered;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _add() async {
    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (c) => _NoteDialog(),
    );

    if (res != null) {
      try {
        await _service.create(
          res['title'] ?? '',
          res['body'] ?? '',
          category: res['category'] ?? '',
        );
        await _load();
        _showSuccess('Note created successfully!');
      } catch (e) {
        _showError('Failed to create note: $e');
      }
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.delete(id);
        await _load();
        _showSuccess('Note deleted successfully!');
      } catch (e) {
        _showError('Failed to delete note: $e');
      }
    }
  }

  Future<void> _togglePin(String id) async {
    try {
      await _service.togglePin(id);
      await _load();
    } catch (e) {
      _showError('Failed to toggle pin: $e');
    }
  }

  Future<void> _editNote(Note note) async {
    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (c) => _NoteDialog(
        initialTitle: note.title,
        initialBody: note.body,
        initialCategory: note.category,
      ),
    );

    if (res != null) {
      try {
        final updatedNote = note.copyWith(
          title: res['title'],
          body: res['body'],
          category: res['category'],
        );
        await _service.update(updatedNote);
        await _load();
        _showSuccess('Note updated successfully!');
      } catch (e) {
        _showError('Failed to update note: $e');
      }
    }
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: (value) {
        setState(() {
          if (value == 'pinned_toggle') {
            _showPinnedFirst = !_showPinnedFirst;
          } else {
            _sortBy = value;
          }
        });
        _filterNotes();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'modified',
          child: Row(
            children: [
              Icon(Icons.access_time, size: 20),
              const SizedBox(width: 8),
              const Text('Last Modified'),
              if (_sortBy == 'modified') const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'created',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              const Text('Date Created'),
              if (_sortBy == 'created') const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'title',
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha, size: 20),
              const SizedBox(width: 8),
              const Text('Alphabetical'),
              if (_sortBy == 'title') const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'pinned_toggle',
          child: Row(
            children: [
              Icon(Icons.push_pin, size: 20),
              const SizedBox(width: 8),
              const Text('Pinned First'),
              if (_showPinnedFirst) const Icon(Icons.check, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedCategory.isEmpty,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = '';
              });
              _filterNotes();
            },
          ),
          const SizedBox(width: 8),
          ..._categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : '';
                  });
                  _filterNotes();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          _buildSortMenu(),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    const Icon(Icons.backup),
                    const SizedBox(width: 8),
                    const Text('Backup Notes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    const Icon(Icons.restore),
                    const SizedBox(width: 8),
                    const Text('Restore Notes'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'backup') {
                try {
                  await _service.backup();
                  _showSuccess('Notes backed up successfully!');
                } catch (e) {
                  _showError('Backup failed: $e');
                }
              } else if (value == 'restore') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Restore Backup'),
                    content: const Text(
                      'This will replace all current notes. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Restore'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    final success = await _service.restore();
                    if (success) {
                      await _load();
                      _showSuccess('Notes restored successfully!');
                    } else {
                      _showError('No backup found');
                    }
                  } catch (e) {
                    _showError('Restore failed: $e');
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Category Filter
          if (_categories.isNotEmpty) _buildCategoryFilter(),

          // Notes List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No notes found'
                              : 'No notes yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Try different search terms'
                              : 'Tap the + button to create your first note',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, i) {
                      final n = _filteredNotes[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: n.isPinned
                                ? Colors.orange.withOpacity(0.2)
                                : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                            child: Icon(
                              n.isPinned ? Icons.push_pin : Icons.note,
                              color: n.isPinned
                                  ? Colors.orange
                                  : Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title.isEmpty ? 'Untitled' : n.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: n.isPinned
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (n.category.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    n.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (n.body.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  n.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Modified ${_formatDate(n.modifiedAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'pin',
                                child: Row(
                                  children: [
                                    Icon(
                                      n.isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(n.isPinned ? 'Unpin' : 'Pin'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _editNote(n);
                                  break;
                                case 'pin':
                                  _togglePin(n.id);
                                  break;
                                case 'delete':
                                  _delete(n.id);
                                  break;
                              }
                            },
                          ),
                          onTap: () => _editNote(n),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  final String initialTitle;
  final String initialBody;
  final String initialCategory;

  const _NoteDialog({
    this.initialTitle = '',
    this.initialBody = '',
    this.initialCategory = '',
  });

  @override
  _NoteDialogState createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String _selectedCategory = '';

  final List<String> _availableCategories = [
    'Personal',
    'Work',
    'Study',
    'Ideas',
    'Shopping',
    'Travel',
    'Health',
    'Finance',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialBody);
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTitle.isEmpty ? 'New Note' : 'Edit Note'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select category (optional)'),
              items: [
                const DropdownMenuItem(value: '', child: Text('No category')),
                ..._availableCategories.map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? '';
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'title': _titleController.text,
              'body': _bodyController.text,
              'category': _selectedCategory,
            });
          },
          child: Text(widget.initialTitle.isEmpty ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
