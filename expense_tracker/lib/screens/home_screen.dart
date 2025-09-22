import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'add_time_entry_screen.dart';
import 'manage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _grouped = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);
    if (!provider.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final entries = provider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_grouped ? Icons.list : Icons.folder_open),
            tooltip: _grouped ? 'Show flat list' : 'Group by project',
            onPressed: () => setState(() => _grouped = !_grouped),
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Seed demo entries',
            onPressed: () async {
              await Provider.of<TimeEntryProvider>(
                context,
                listen: false,
              ).seedDemoEntries();
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo entries seeded')),
                );
            },
          ),
        ],
      ),
      drawer: Drawer(child: ManageScreen()),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No time entries yet!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add your first entry.'),
                ],
              ),
            )
          : _grouped
          ? _buildGrouped(provider)
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final project = provider.projects.firstWhere(
                  (p) => p.id == e.projectId,
                  orElse: () => Project(id: '0', name: 'Unknown'),
                );
                final task = provider.tasks.firstWhere(
                  (t) => t.id == e.taskId,
                  orElse: () => Task(id: '0', name: 'Unknown'),
                );
                return Dismissible(
                  key: Key(e.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => provider.deleteEntry(e.id),
                  child: ListTile(
                    title: Text('${project.name} • ${task.name}'),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(e.date)} — ${e.minutes} min',
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditTimeEntryScreen(entryId: e.id),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTimeEntryScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrouped(TimeEntryProvider provider) {
    final grouped = provider.groupedByProject();
    final projectMap = {for (var p in provider.projects) p.id: p};
    final keys = grouped.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final pid = keys[i];
        final project = projectMap[pid] ?? Project(id: '0', name: 'Unknown');
        final items = grouped[pid] ?? [];
        return ExpansionTile(
          title: Text(project.name),
          leading: const Icon(Icons.folder),
          children: items.map((e) {
            final task = provider.tasks.firstWhere(
              (t) => t.id == e.taskId,
              orElse: () => Task(id: '0', name: 'Unknown'),
            );
            return ListTile(
              title: Text(task.name),
              subtitle: Text(
                '${DateFormat.yMMMd().format(e.date)} — ${e.minutes} min',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => provider.deleteEntry(e.id),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditTimeEntryScreen(entryId: e.id),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
