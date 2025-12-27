import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider for Task List (AsyncValue)
final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskListNotifier(ref.watch(apiServiceProvider));
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _apiService;

  TaskListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _apiService.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Task?> addTask(Task task) async {
    try {
      // Optimistic update or wait for server? Let's wait for server to get the Classification data.
      final createdTask = await _apiService.createTask(task);
      state.whenData((tasks) {
        state = AsyncValue.data([createdTask, ...tasks]);
      });
      return createdTask;
    } catch (e) {
      // Handle error (maybe show toast in UI)
      print("Error creating task: $e");
      return null;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _apiService.updateTaskStatus(id, status);
      // Update local state
      state.whenData((tasks) {
        state = AsyncValue.data(tasks.map((t) {
          if (t.id == id) {
             // Create copy with new status (assuming Task is immutable/copyWith exists, else manually)
             // simplified manual copy since I didn't write a copyWith in the model earlier
             return Task(
               id: t.id,
               title: t.title,
               description: t.description,
               category: t.category,
               priority: t.priority,
               status: status,
               assignedTo: t.assignedTo,
               dueDate: t.dueDate,
               suggestedActions: t.suggestedActions,
             );
          }
          return t;
        }).toList());
      });
    } catch (e) {
      print("Error updating task: $e");
    }
  }
}
