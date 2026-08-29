class FunctionalAreaRequest {
  final String location;
  final String area;
  final String deckLevel;
  final String? subArea;
  final String zone;
  final List<String> locationGasGroup;
  final List<String> locationTClass;
  final List<String> locationIpRating;
  final String tAmbient;
  final List<String> areaClassDrawAttach;
  final List<String> areaClassDrawNo;
  final List<String> areaClassDrawAttachOrgName;
  final List<String> eqpmtLytDrawAttach;
  final List<String> eqpmtLytDrawNo;
  final List<String> eqpmtLytDrawAttachOrgName;
  String? locationId;
  final String? locationLatitude;
  final String? locationLongitude;
  final bool isActive;
  dynamic areaStatus;

  FunctionalAreaRequest({
    required this.location,
    required this.area,
    required this.zone,
    required this.deckLevel,
    this.subArea,
    required this.locationGasGroup,
    required this.locationTClass,
    required this.locationIpRating,
    required this.tAmbient,
    required this.areaClassDrawAttach,
    required this.areaClassDrawNo,
    required this.eqpmtLytDrawAttach,
    required this.eqpmtLytDrawNo,
    this.locationId,
    this.locationLatitude,
    this.locationLongitude,
    required this.areaClassDrawAttachOrgName,
    required this.eqpmtLytDrawAttachOrgName,
    required this.isActive,
    this.areaStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': {
        'location': location,
        'area': area,
        'deckLevel': deckLevel,
        'subArea': subArea,
        'zone': zone,
        'locationGasGroup': locationGasGroup,
        'locationTClass': locationTClass,
        'locationIpRating': locationIpRating,
        'tAmbient': tAmbient,
        'areaClassDrawAttach': areaClassDrawAttach,
        'areaClassDrawNo': areaClassDrawNo,
        'areaClassDrawAttachOrgName': areaClassDrawAttachOrgName,
        'eqpmtLytDrawAttachOrgName': eqpmtLytDrawAttachOrgName,
        'eqpmtLytDrawAttach': eqpmtLytDrawAttach,
        'eqpmtLytDrawNo': eqpmtLytDrawNo,
        'locationId': locationId,
        'locationLongitude': locationLongitude,
        'locationLatitude': locationLatitude,
        'isActive': isActive,
        'areaStatus': areaStatus,
      },
    };
  }

  factory FunctionalAreaRequest.fromJson(Map<String, dynamic> json) {
    return FunctionalAreaRequest(
      locationId: json['_id'] ?? json['locationId'],
      location: json['location'] ?? '',
      area: json['area'] ?? '',
      deckLevel: json['deckLevel'],
      subArea: json['subArea'],
      zone: json['zone'],
      locationGasGroup: List<String>.from(json['locationGasGroup'] ?? []),
      locationTClass: List<String>.from(json['locationTClass'] ?? []),
      locationIpRating: List<String>.from(json['locationIpRating'] ?? []),
      areaClassDrawNo: List<String>.from(json['areaClassDrawNo'] ?? []),
      areaClassDrawAttachOrgName: List<String>.from(
        json['areaClassDrawAttachOrgName'] ?? [],
      ),
      areaClassDrawAttach: List<String>.from(json['areaClassDrawAttach'] ?? []),
      locationLatitude: json['locationLatitude'] ?? '',
      locationLongitude: json['locationLongitude'] ?? '',
      eqpmtLytDrawAttachOrgName: List<String>.from(
        json['eqpmtLytDrawAttachOrgName'] ?? [],
      ),
      eqpmtLytDrawAttach: List<String>.from(json['eqpmtLytDrawAttach'] ?? []),
      eqpmtLytDrawNo: List<String>.from(json['eqpmtLytDrawNo'] ?? []),
      tAmbient: json['tAmbient'].toString(),
      isActive: json['isActive'],
      areaStatus: json['areaStatus'],
    );
  }
}
