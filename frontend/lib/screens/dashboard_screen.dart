import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Site Task Manager')),
      body: tasksAsync.when(
        data: (tasks) => _buildDashboardContent(context, tasks, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, List<Task> tasks, WidgetRef ref) {
    final pending = tasks.where((t) => t.status == 'pending').length;
    final inProgress = tasks.where((t) => t.status == 'in_progress').length;
    final completed = tasks.where((t) => t.status == 'completed').length;

    return Column(
      children: [
        // Summary Cards
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard("Pending", pending, Colors.orange),
              _buildSummaryCard("Active", inProgress, Colors.blue),
              _buildSummaryCard("Done", completed, Colors.green),
            ],
          ),
        ),
        const Divider(),
        // Task List
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(task.category),
                    child: Icon(_getCategoryIcon(task.category),
                        color: Colors.white, size: 20),
                  ),
                  title: Text(task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(task.priority),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(task.priority.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                          const Spacer(),
                          Text(task.status,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Show details or actions
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  const SizedBox(height: 10),
                                  Text("Category: ${task.category}"),
                                  Text("Suggested Actions:"),
                                  ...task.suggestedActions
                                      .map((a) => Text("• $a")),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(taskListProvider.notifier)
                                                .updateStatus(
                                                    task.id!, 'in_progress');
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Start")),
                                      ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(taskListProvider.notifier)
                                                .updateStatus(
                                                    task.id!, 'completed');
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Complete")),
                                    ],
                                  )
                                ],
                              ),
                            ));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(count.toString(),
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'safety':
        return Colors.red;
      case 'finance':
        return Colors.green;
      case 'technical':
        return Colors.blueGrey;
      case 'scheduling':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'safety':
        return Icons.warning;
      case 'finance':
        return Icons.attach_money;
      case 'technical':
        return Icons.build;
      case 'scheduling':
        return Icons.calendar_today;
      default:
        return Icons.task;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.green;
    }
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("New Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: titleCtrl,
                      decoration:
                          const InputDecoration(labelText: "Task Title")),
                  TextField(
                      controller: descCtrl,
                      decoration:
                          const InputDecoration(labelText: "Description")),
                  const SizedBox(height: 10),
                  const Text("Category and Priority will be auto-detected.",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.isNotEmpty) {
                        // 1. Create task and wait for backend analysis
                        final newTask = await ref
                            .read(taskListProvider.notifier)
                            .addTask(Task(
                              title: titleCtrl.text,
                              description: descCtrl.text,
                            ));

                        Navigator.pop(ctx); // Close the input sheet

                        // 2. Show the result dialog "Success Criteria"
                        if (newTask != null && context.mounted) {
                          showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                    title: const Text("✨ Task Analyzed"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Category: ${newTask.category}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text("Priority: ${newTask.priority}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 10),
                                        const Text(
                                            "Stored in Database (Mock)."),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(c),
                                          child: const Text("OK"))
                                    ],
                                  ));
                        }
                      }
                    },
                    child: const Text("Analyze & Create Task")),
              ],
            ));
  }
}
