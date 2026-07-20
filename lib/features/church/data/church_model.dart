class ChurchModel {
  final String id;
  final String name;
  final String location;
  final String diocese;
  final String? logoUrl;
  final String? adminUid;
  final int memberCount;
  final bool isMonastery;

  ChurchModel({
    required this.id,
    required this.name,
    required this.location,
    required this.diocese,
    this.logoUrl,
    this.adminUid,
    this.memberCount = 0,
    this.isMonastery = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'diocese': diocese,
      'logoUrl': logoUrl,
      'adminUid': adminUid,
      'memberCount': memberCount,
      'isMonastery': isMonastery,
    };
  }

  factory ChurchModel.fromMap(Map<String, dynamic> map, String id) {
    return ChurchModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      diocese: map['diocese'] ?? '',
      logoUrl: map['logoUrl'],
      adminUid: map['adminUid'],
      memberCount: map['memberCount'] ?? 0,
      isMonastery: map['isMonastery'] ?? false,
    );
  }
}
