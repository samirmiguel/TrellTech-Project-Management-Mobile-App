class Workspace {
  final String id;
  final String name;
  final String description;

  Workspace({this.id, this.name, this.description});

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      description: json['desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': description,
    };
  }
}
