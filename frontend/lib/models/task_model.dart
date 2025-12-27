class Task {
  final String? id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime? dueDate;
  final List<String> suggestedActions;

  Task({
    this.id,
    required this.title,
    this.description,
    this.category = 'general',
    this.priority = 'low',
    this.status = 'pending',
    this.assignedTo,
    this.dueDate,
    this.suggestedActions = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'low',
      status: json['status'] ?? 'pending',
      assignedTo: json['assigned_to'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      suggestedActions: json['suggested_actions'] != null 
          ? List<String>.from(json['suggested_actions']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}
