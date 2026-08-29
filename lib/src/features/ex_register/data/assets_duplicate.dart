import 'dart:convert';

DuplicateAsset duplicateAssetFromJson(String str) =>
    DuplicateAsset.fromJson(json.decode(str));
String duplicateAssetToJson(DuplicateAsset data) => json.encode(data.toJson());

class DuplicateAsset {
  dynamic createdAt;
  dynamic updatedAt;
  dynamic gpsCord;
  // dynamic inspectionReferenceNumber;
  dynamic tAmbient;
  dynamic tAmbientEquip;
  dynamic equipmentTClass;
  dynamic type;
  dynamic eqpmtCatg;
  dynamic oracleId;
  dynamic isActive;
  dynamic specialCond;
  dynamic rfidRef;
  dynamic serialNumber;
  dynamic protectionStd;
  dynamic protectionType;
  dynamic manufacturer;
  dynamic equipmentIpRating;
  dynamic equipmentGasGroup;
  dynamic description;
  dynamic epl;
  dynamic eqpmtTag;
  dynamic createdBy;
  dynamic atexCatg;
  dynamic certfnBody;
  dynamic certfnNo;
  dynamic circuitId;
  dynamic cableId;
  dynamic equipmentCategory;
  dynamic location;
  List<String> areaClassDrawNo;
  List<String> areaClassDrawAttach;
  List<String> areaClassDrawAttachOrgName;
  List<String> eqpmtLytDrawNo;
  List<String> eqpmtLytDrawAttach;
  List<String> eqpmtLytDrawAttachOrgName;
  dynamic subArea;
  dynamic area;
  dynamic locationLatitude;
  dynamic locationLongitude;
  dynamic zone;
  dynamic locationGasGroup;
  dynamic locationTClass;
  dynamic locationIpRating;
  dynamic locationId;
  dynamic deckLevel;
  dynamic locationTAmbient;
  dynamic isDuplicate;
  DuplicateAsset({
    this.createdAt,
    this.updatedAt,
    this.gpsCord,
    // this.inspectionReferenceNumber,
    this.tAmbient,
    this.tAmbientEquip,
    this.equipmentTClass,
    this.type,
    this.eqpmtCatg,
    this.oracleId,
    required this.isActive,
    this.specialCond,
    this.rfidRef,
    this.serialNumber,
    this.protectionStd,
    this.protectionType,
    this.manufacturer,
    this.equipmentIpRating,
    this.equipmentGasGroup,
    this.description,
    this.epl,
    this.eqpmtTag,
    this.createdBy,
    this.atexCatg,
    this.certfnBody,
    this.certfnNo,
    this.circuitId,
    this.cableId,
    this.equipmentCategory,
    this.location,
    required this.areaClassDrawNo,
    required this.areaClassDrawAttach,
    required this.areaClassDrawAttachOrgName,
    required this.eqpmtLytDrawAttachOrgName,
    required this.eqpmtLytDrawNo,
    required this.eqpmtLytDrawAttach,
    this.subArea,
    this.area,
    this.locationLatitude,
    this.locationLongitude,
    this.zone,
    this.locationGasGroup,
    this.locationTClass,
    this.locationIpRating,
    this.locationId,
    this.deckLevel,
    this.locationTAmbient,
    this.isDuplicate,
  });

  factory DuplicateAsset.fromJson(Map<String, dynamic> json) => DuplicateAsset(
        createdAt: json["createdAt"] ?? '',
        updatedAt: json["updatedAt"] ?? '',
        gpsCord: json["gpsCord"] ?? '',
        // inspectionReferenceNumber: json["inspectionReferenceNumber"]??'',
        tAmbient: json["tAmbient"] ?? '',
        tAmbientEquip: json["tAmbientEquip"] ?? '',
        equipmentTClass: json["equipmentTClass"] ?? '',
        type: json["type"] ?? '',
        eqpmtCatg: json["eqpmtCatg"] ?? '',
        oracleId: json["oracleId"] ?? '',
        isActive: json["isActive"],
        specialCond: json["specialCond"] ?? '',
        rfidRef: '',
        serialNumber: json["serialNumber"] ?? '',
        protectionStd: json["protectionStd"] ?? '',
        protectionType: json["protectionType"] ?? '',
        manufacturer: json["manufacturer"] ?? '',
        equipmentIpRating: json["equipmentIpRating"] ?? '',
        equipmentGasGroup: json["equipmentGasGroup"] ?? '',
        description: json["description"] ?? '',
        epl: json["epl"] ?? '',
        eqpmtTag: json["eqpmtTag"] ?? '',
        createdBy: json["createdBy"] ?? '',
        atexCatg: json["atexCatg"] ?? '',
        certfnBody: json["certfnBody"] ?? '',
        certfnNo: json["certfnNo"] ?? '',
        circuitId: json["circuitId"] ?? '',
        cableId: json["cableId"] ?? '',
        equipmentCategory: json["equipmentCategory"] ?? '',
        location: json["location"] ?? '',
        areaClassDrawNo: List<String>.from(json["areaClassDrawNo"] ?? []),
        areaClassDrawAttach:
            List<String>.from(json["areaClassDrawAttach"] ?? []),
        areaClassDrawAttachOrgName:
            List<String>.from(json["areaClassDrawAttachOrgName"] ?? []),
        eqpmtLytDrawAttachOrgName:
            List<String>.from(json["eqpmtLytDrawAttachOrgName"] ?? []),
        eqpmtLytDrawNo: List<String>.from(json["eqpmtLytDrawNo"] ?? []),
        eqpmtLytDrawAttach: List<String>.from(json["eqpmtLytDrawAttach"] ?? []),
        subArea: json["subArea"] ?? '',
        area: json["area"] ?? '',
        locationLatitude: json["locationLatitude"] ?? '',
        locationLongitude: json["locationLongitude"] ?? '',
        zone: json["zone"] ?? '',
        locationGasGroup: json["locationGasGroup"] ?? '',
        locationTClass: json["locationTClass"] ?? '',
        locationIpRating: json["locationIpRating"] ?? '',
        locationId: json["locationId"] ?? '',
        deckLevel: json["deckLevel"] ?? '',
        locationTAmbient: json["locationTAmbient"] ?? '',
        isDuplicate: json["isDuplicate"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "gpsCord": gpsCord,
        // "inspectionReferenceNumber": inspectionReferenceNumber,
        "tAmbient": tAmbient,
        "tAmbientEquip": tAmbientEquip,
        "equipmentTClass": equipmentTClass,
        "type": type,
        "eqpmtCatg": eqpmtCatg,
        "oracleId": oracleId,
        "isActive": isActive,
        "specialCond": specialCond,
        "rfidRef": rfidRef,
        "serialNumber": serialNumber,
        "protectionStd": protectionStd,
        "protectionType": protectionType,
        "manufacturer": manufacturer,
        "equipmentIpRating": equipmentIpRating,
        "equipmentGasGroup": equipmentGasGroup,
        "description": description,
        "epl": epl,
        "eqpmtTag": eqpmtTag,
        "createdBy": createdBy,
        "atexCatg": atexCatg,
        "certfnBody": certfnBody,
        "certfnNo": certfnNo,
        "circuitId": circuitId,
        "cableId": cableId,
        "equipmentCategory": equipmentCategory,
        "location": location,
        "areaClassDrawNo": areaClassDrawNo,
        "areaClassDrawAttach": areaClassDrawAttach,
        "areaClassDrawAttachOrgName": areaClassDrawAttachOrgName,
        "eqpmtLytDrawAttachOrgName": eqpmtLytDrawAttachOrgName,
        "eqpmtLytDrawNo": eqpmtLytDrawNo,
        "eqpmtLytDrawAttach": eqpmtLytDrawAttach,
        "subArea": subArea,
        "area": area,
        "locationLatitude": locationLatitude,
        "locationLongitude": locationLongitude,
        "zone": zone,
        "locationGasGroup": locationGasGroup,
        "locationTClass": locationTClass,
        "locationIpRating": locationIpRating,
        "locationId": locationId,
        "deckLevel": deckLevel,
        "locationTAmbient": locationTAmbient,
        "isDuplicate": isDuplicate,
      };
}
