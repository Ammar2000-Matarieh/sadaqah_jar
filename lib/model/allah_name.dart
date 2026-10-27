class AllahName {
  final int id;
  final String name;

  const AllahName({required this.id, required this.name});

  factory AllahName.fromJson(Map<String, dynamic> json) => AllahName(
    id: (json['id'] ?? json['number']) as int,
    name: (json['name'] ?? json['arabic']) as String,
  );
}
