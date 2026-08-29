class Activity {
  final int? id;
  final String? assetId;
  final FunctionalityType functionality;
  final String functionalityApiResponseId;
  final bool status;
  final String lastSync;
  final String createdBy;
  final String updatedBy;

  Activity({
    this.id,
    required this.assetId,
    required this.functionality,
    required this.functionalityApiResponseId,
    required this.status,
    required this.lastSync,
    required this.createdBy,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'assetId': assetId,
      'functionality': functionality.toString().split('.')[1],
      'functionality_api_response_id': functionalityApiResponseId,
      'status': status ? 1 : 0,
      'lastSync': lastSync,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      assetId: map['master_id'] as String,
      functionality: FunctionalityType.values.firstWhere(
        (e) => e.toString().split('.')[1] == map['functionality'],),
      functionalityApiResponseId: map['functionality_api_response_id'] as String,
      status: map['status'] == 1,
      lastSync: map['lastSync'] as String,
      createdBy: map['created_by'] as String,
      updatedBy: map['updated_by'] as String,
    );
  }
}

enum FunctionalityType {
  location,
  asset,
  fileUpload,
  imageUpload
}
