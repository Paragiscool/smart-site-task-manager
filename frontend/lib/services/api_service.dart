import 'package:dio/dio.dart';
import '../models/task_model.dart'; // Assumes model exists as per existing file

class ApiService {
  // Use localhost for iOS simulator/Android emulator needs special handling (10.0.2.2)
  // For Windows/Web, localhost is fine.
  // We use 10.0.2.2 to allow default Android emulators to access the host machine's localhost.
  // If running on Web or iOS, you might need to swap this back to localhost.
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/api', 
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get('/tasks');
      return (response.data as List).map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post('/tasks', data: task.toJson());
      return Task.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
    try {
      await _dio.patch('/tasks/$id', data: {'status': status});
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
