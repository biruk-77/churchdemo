class ChurchModel {
  final String id;
  final String name;
  final String location;
  final String diocese;
  final String dioceseName;
  final String? woreda;
  final String? woredaName;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? adminUid;
  final int memberCount;
  final bool isMonastery;
  final String? clergy;
  final int? foundingYear;
  final String status;

  ChurchModel({
    required this.id,
    required this.name,
    required this.location,
    required this.diocese,
    required this.dioceseName,
    this.woreda,
    this.woredaName,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.adminUid,
    this.memberCount = 0,
    this.isMonastery = false,
    this.clergy,
    this.foundingYear,
    this.status = 'verified',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'diocese': diocese,
      'dioceseName': dioceseName,
      'woreda': woreda,
      'woredaName': woredaName,
      'latitude': latitude,
      'longitude': longitude,
      'logoUrl': logoUrl,
      'adminUid': adminUid,
      'memberCount': memberCount,
      'isMonastery': isMonastery,
      'clergy': clergy,
      'foundingYear': foundingYear,
      'status': status,
    };
  }

  factory ChurchModel.fromMap(Map<String, dynamic> map, String id) {
    return ChurchModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      diocese: map['diocese'] ?? '',
      dioceseName: map['dioceseName'] ?? map['diocese'] ?? '',
      woreda: map['woreda'],
      woredaName: map['woredaName'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      logoUrl: map['logoUrl'],
      adminUid: map['adminUid'],
      memberCount: map['memberCount'] ?? 0,
      isMonastery: map['isMonastery'] ?? false,
      clergy: map['clergy'],
      foundingYear: map['foundingYear'],
      status: map['status'] ?? 'verified',
    );
  }
}
