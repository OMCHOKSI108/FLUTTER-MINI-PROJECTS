class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final int minutes; // store total minutes
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.minutes,
    required this.date,
    this.notes = '',
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
    id: json['id'].toString(),
    projectId: json['projectId'].toString(),
    taskId: json['taskId'].toString(),
    minutes: (json['minutes'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
    notes: json['notes'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'taskId': taskId,
    'minutes': minutes,
    'date': date.toIso8601String(),
    'notes': notes,
  };
}
