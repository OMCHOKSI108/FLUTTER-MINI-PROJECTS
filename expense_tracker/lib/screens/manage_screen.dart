import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<TimeEntryProvider>(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.primary,
            width: double.infinity,
            child: const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Projects'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ManageProjectsTasksScreen(isProject: true),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Tasks'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ManageProjectsTasksScreen(isProject: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManageProjectsTasksScreen extends StatefulWidget {
  final bool isProject;
  const ManageProjectsTasksScreen({super.key, required this.isProject});

  @override
  State<ManageProjectsTasksScreen> createState() =>
      _ManageProjectsTasksScreenState();
}

class _ManageProjectsTasksScreenState extends State<ManageProjectsTasksScreen> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);
    final items = widget.isProject ? provider.projects : provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isProject ? 'Manage Projects' : 'Manage Tasks'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];
              final title = widget.isProject
                  ? (it as Project).name
                  : (it as Task).name;
              return ListTile(
                title: Text(title),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (widget.isProject) {
                      provider.deleteProject((it as Project).id);
                    } else {
                      provider.deleteTask((it as Task).id);
                    }
                  },
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 6,
              onPressed: () async {
                String? result;
                await showDialog<void>(
                  context: context,
                  builder: (c) {
                    return StatefulBuilder(
                      builder: (ctx, setState) {
                        String? error;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: Text(
                            widget.isProject ? 'Add Project' : 'Add Task',
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  errorText: error,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(c).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_textController.text.trim().isEmpty) {
                                  setState(() {
                                    error = 'Name required';
                                  });
                                  return;
                                }
                                result = _textController.text.trim();
                                Navigator.of(c).pop();
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
                if (result != null && result!.isNotEmpty) {
                  final name = result!;
                  if (widget.isProject) {
                    provider.addProject(
                      Project(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                      ),
                    );
                  } else {
                    provider.addTask(
                      Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                      ),
                    );
                  }
                  _textController.clear();
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
