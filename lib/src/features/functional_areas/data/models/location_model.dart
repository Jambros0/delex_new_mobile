class Location {
  String? id;
  final String location;
  final String area;
  final String? deckLevel;
  final String? subArea;
  final String? zone;
  List<String> locationGasGroup;
  List<String> locationTClass;
  List<String> locationIpRating;
  final bool isActive;
  final dynamic gpsCoordinates;
  final dynamic locationLongitude;
  final dynamic locationLatitude;
  List<String> areaClassDrawAttach;
  List<String> areaClassDrawNo;
  List<String> areaClassDrawAttachOrgName;
  List<String> eqpmtLytDrawAttachOrgName;
  List<String> eqpmtLytDrawAttach;
  List<String> eqpmtLytDrawNo;
  final dynamic tAmbient;

  Location(
      {this.id,
      required this.location,
      required this.area,
      this.deckLevel,
      this.subArea,
      this.zone,
      required this.locationGasGroup,
      required this.locationTClass,
      required this.locationIpRating,
      required this.isActive,
      this.gpsCoordinates,
      this.locationLongitude,
      this.locationLatitude,
      required this.eqpmtLytDrawAttachOrgName,
      required this.areaClassDrawAttachOrgName,
      required this.eqpmtLytDrawAttach,
      required this.areaClassDrawAttach,
      required this.areaClassDrawNo,
      required this.eqpmtLytDrawNo,
      this.tAmbient});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        id: json['_id'] ?? json['locationId'] ?? '',
        location: json['location'] ?? '',
        area: json['area'] ?? '',
        deckLevel: json['deckLevel'],
        subArea: json['subArea'],
        zone: json['zone'],
        locationGasGroup: List<String>.from(json['locationGasGroup'] ?? []),
        locationTClass: List<String>.from(json['locationTClass'] ?? []),
        locationIpRating: List<String>.from(json['locationIpRating'] ?? []),
        isActive: json['isActive'] ?? true,
        gpsCoordinates: json['gpsCoordinates'] ?? '',
        locationLongitude: json['locationLongitude'] ?? '',
        locationLatitude: json['locationLatitude'] ?? '',
        areaClassDrawAttach:
            List<String>.from(json['areaClassDrawAttach'] ?? []),
        areaClassDrawAttachOrgName:
            List<String>.from(json['areaClassDrawAttachOrgName'] ?? []),
        eqpmtLytDrawAttachOrgName:
            List<String>.from(json['eqpmtLytDrawAttachOrgName'] ?? []),
        eqpmtLytDrawAttach: List<String>.from(json['eqpmtLytDrawAttach'] ?? []),
        areaClassDrawNo: List<String>.from(json['areaClassDrawNo'] ?? []),
        eqpmtLytDrawNo: List<String>.from(json['eqpmtLytDrawNo'] ?? []),
        tAmbient: json['tAmbient'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'location': location,
      'deckLevel': deckLevel,
      'area': area,
      'subArea': subArea,
      'zone': zone,
      'locationGasGroup': locationGasGroup,
      'locationTClass': locationTClass,
      'locationIpRating': locationIpRating,
      'isActive': isActive,
      'gpsCoordinates': gpsCoordinates,
      'locationLongitude': locationLongitude,
      'locationLatitude': locationLatitude,
      'areaClassDrawNo': areaClassDrawNo,
      'eqpmtLytDrawNo': eqpmtLytDrawNo,
      'areaClassDrawAttach': areaClassDrawAttach,
      'areaClassDrawAttachOrgName': areaClassDrawAttachOrgName,
      'eqpmtLytDrawAttachOrgName': eqpmtLytDrawAttachOrgName,
      'eqpmtLytDrawAttach': eqpmtLytDrawAttach,
      'tAmbient': tAmbient
    };
  }
}
