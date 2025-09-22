class Project {
  final String id;
  final String name;
  bool isDefault;

  Project({required this.id, required this.name, this.isDefault = false});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'].toString(),
    name: json['name'] as String,
    isDefault: json['isDefault'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isDefault': isDefault,
  };
}
