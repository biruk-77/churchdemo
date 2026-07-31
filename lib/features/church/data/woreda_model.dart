class WoredaModel {
  final String id;
  final String name;
  final String dioceseName;
  final String dioceseId;
  final int churchCount;

  WoredaModel({
    required this.id,
    required this.name,
    required this.dioceseName,
    required this.dioceseId,
    this.churchCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dioceseName': dioceseName,
      'dioceseId': dioceseId,
      'churchCount': churchCount,
    };
  }

  factory WoredaModel.fromMap(Map<String, dynamic> map, String id) {
    return WoredaModel(
      id: id,
      name: map['name'] ?? '',
      dioceseName: map['dioceseName'] ?? '',
      dioceseId: map['dioceseId'] ?? '',
      churchCount: map['churchCount'] ?? 0,
    );
  }
}
