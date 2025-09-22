class Task {
  final String id;
  final String name;

  Task({required this.id, required this.name});

  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(id: json['id'].toString(), name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
