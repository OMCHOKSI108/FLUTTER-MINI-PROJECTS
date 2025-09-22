import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  String? _selectedProjectId;
  String? _selectedTaskId;
  final _minutesController = TextEditingController();
  DateTime _date = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);
    final projects = provider.projects;
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProjectId,
              items: projects
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedProjectId = v),
              decoration: const InputDecoration(labelText: 'Project'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTaskId,
              items: tasks
                  .map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedTaskId = v),
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total minutes'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Date: ${DateFormat.yMMMd().format(_date)}'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_selectedProjectId == null ||
                    _selectedTaskId == null ||
                    _minutesController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                    ),
                  );
                  return;
                }
                final entry = TimeEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  projectId: _selectedProjectId!,
                  taskId: _selectedTaskId!,
                  minutes: int.tryParse(_minutesController.text) ?? 0,
                  date: _date,
                  notes: _notesController.text,
                );
                await provider.addEntry(entry);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTimeEntryScreen extends StatefulWidget {
  final String entryId;
  const EditTimeEntryScreen({super.key, required this.entryId});

  @override
  State<EditTimeEntryScreen> createState() => _EditTimeEntryScreenState();
}

class _EditTimeEntryScreenState extends State<EditTimeEntryScreen> {
  String? _selectedProjectId;
  String? _selectedTaskId;
  final _minutesController = TextEditingController();
  DateTime _date = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<TimeEntryProvider>(context);
    final entry = provider.entries.firstWhere(
      (e) => e.id == widget.entryId,
      orElse: () => TimeEntry(
        id: '',
        projectId: '',
        taskId: '',
        minutes: 0,
        date: DateTime.now(),
      ),
    );
    if (entry.id.isEmpty) return; // entry not found, skip prefill
    _selectedProjectId = entry.projectId;
    _selectedTaskId = entry.taskId;
    _minutesController.text = entry.minutes.toString();
    _date = entry.date;
    _notesController.text = entry.notes;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);
    final projects = provider.projects;
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProjectId,
              items: projects
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedProjectId = v),
              decoration: const InputDecoration(labelText: 'Project'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTaskId,
              items: tasks
                  .map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedTaskId = v),
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total minutes'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Date: ${DateFormat.yMMMd().format(_date)}'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_selectedProjectId == null ||
                    _selectedTaskId == null ||
                    _minutesController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                    ),
                  );
                  return;
                }
                final entry = TimeEntry(
                  id: widget.entryId,
                  projectId: _selectedProjectId!,
                  taskId: _selectedTaskId!,
                  minutes: int.tryParse(_minutesController.text) ?? 0,
                  date: _date,
                  notes: _notesController.text,
                );
                await provider.updateEntry(entry);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
