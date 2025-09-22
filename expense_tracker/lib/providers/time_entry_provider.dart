import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';

import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class TimeEntryProvider extends ChangeNotifier {
  final LocalStorage storage = LocalStorage('time_tracker');

  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _entries = [];
  bool _ready = false;

  bool get ready => _ready;

  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<TimeEntry> get entries => List.unmodifiable(_entries);

  TimeEntryProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    await storage.ready;

    final projectsJson = storage.getItem('projects');
    final tasksJson = storage.getItem('tasks');
    final entriesJson = storage.getItem('timeEntries');
    if (projectsJson != null) {
      try {
        List<dynamic> list;
        if (projectsJson is String) {
          list = jsonDecode(projectsJson) as List<dynamic>;
        } else if (projectsJson is List) {
          list = projectsJson;
        } else {
          list = [];
        }
        _projects = list
            .map((e) => Project.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (tasksJson != null) {
      try {
        List<dynamic> list;
        if (tasksJson is String) {
          list = jsonDecode(tasksJson) as List<dynamic>;
        } else if (tasksJson is List) {
          list = tasksJson;
        } else {
          list = [];
        }
        _tasks = list
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (entriesJson != null) {
      try {
        List<dynamic> list;
        if (entriesJson is String) {
          list = jsonDecode(entriesJson) as List<dynamic>;
        } else if (entriesJson is List) {
          list = entriesJson;
        } else {
          list = [];
        }
        _entries = list
            .map((e) => TimeEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // If no projects/tasks exist, seed with sample data on first run
    if (_projects.isEmpty && _tasks.isEmpty) {
      final p1 = Project(id: '1', name: 'AIML Project ');
      final p2 = Project(id: '2', name: 'Siraj bhati');
      final p3 = Project(id: '3', name: 'Pranav Sharma');
      final p4 = Project(id: '4', name: 'Piya Patel');
      final p5 = Project(id: '5', name: 'gaurav Gupta');
      _projects = [p1, p2, p3, p4, p5];

      final t1 = Task(id: '1', name: 'Design');
      final t2 = Task(id: '2', name: 'Development');
      final t3 = Task(id: '3', name: 'Testing');
      final t4 = Task(id: '4', name: 'Deployment');
      final t5 = Task(id: '5', name: 'Research');
      _tasks = [t1, t2, t3, t4, t5];

      await _saveAll();
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _saveAll() async {
    await storage.ready;
    // Store native structures when possible; localstorage will persist them.
    try {
      await storage.setItem(
        'projects',
        _projects.map((e) => e.toJson()).toList(),
      );
      await storage.setItem('tasks', _tasks.map((e) => e.toJson()).toList());
      await storage.setItem(
        'timeEntries',
        _entries.map((e) => e.toJson()).toList(),
      );
    } catch (_) {
      // Fallback to stringified JSON if setItem fails for complex types
      storage.setItem(
        'projects',
        jsonEncode(_projects.map((e) => e.toJson()).toList()),
      );
      storage.setItem(
        'tasks',
        jsonEncode(_tasks.map((e) => e.toJson()).toList()),
      );
      storage.setItem(
        'timeEntries',
        jsonEncode(_entries.map((e) => e.toJson()).toList()),
      );
    }
  }

  Future<void> addProject(Project p) async {
    _projects.add(p);
    await _saveAll();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    _entries.removeWhere((e) => e.projectId == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> addTask(Task t) async {
    _tasks.add(t);
    await _saveAll();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _entries.removeWhere((e) => e.taskId == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> addEntry(TimeEntry entry) async {
    _entries.add(entry);
    await _saveAll();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateEntry(TimeEntry entry) async {
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      _entries[idx] = entry;
      await _saveAll();
      notifyListeners();
    }
  }

  Map<String, List<TimeEntry>> groupedByProject() {
    final Map<String, List<TimeEntry>> map = {};
    for (var e in _entries) {
      map.putIfAbsent(e.projectId, () => []).add(e);
    }
    return map;
  }

  /// Seeds demo time entries for screenshots or quick testing.
  Future<void> seedDemoEntries() async {
    if (_projects.isEmpty || _tasks.isEmpty) return;
    _entries = [
      TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _projects[0].id,
        taskId: _tasks[1].id,
        minutes: 45,
        date: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Worked on backend',
      ),
      TimeEntry(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        projectId: _projects[1].id,
        taskId: _tasks[0].id,
        minutes: 30,
        date: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'UI updates',
      ),
      TimeEntry(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        projectId: _projects[0].id,
        taskId: _tasks[2].id,
        minutes: 60,
        date: DateTime.now(),
        notes: 'Testing flows',
      ),
      TimeEntry(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        projectId: _projects[2].id,
        taskId: _tasks[4].id,
        minutes: 20,
        date: DateTime.now().subtract(const Duration(days: 3)),
        notes: 'Research notes',
      ),
    ];
    await _saveAll();
    notifyListeners();
  }
}
