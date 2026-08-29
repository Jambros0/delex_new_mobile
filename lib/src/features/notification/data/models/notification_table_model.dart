// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  bool success;
  String message;
  NotificationModelData data;

  NotificationModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationModelData modelData;
    if (json["data"] != null) {
      if (json["data"] is Map<String, dynamic>) {
        modelData = NotificationModelData.fromJson(json["data"]);
      } else if (json["data"] is List) {
        final list = (json["data"] as List);
        modelData = NotificationModelData(
          notifications: List<Notification>.from(
            list.map((x) => Notification.fromJson(x)),
          ),
          pagination: Pagination(
            currentPage: 1,
            totalPages: 1,
            totalCount: list.length,
            hasNextPage: false,
            hasPrevPage: false,
          ),
        );
      } else {
        modelData = NotificationModelData(
          notifications: [],
          pagination: Pagination(
            currentPage: 1,
            totalPages: 1,
            totalCount: 0,
            hasNextPage: false,
            hasPrevPage: false,
          ),
        );
      }
    } else if (json["notifications"] != null && json["notifications"] is List) {
      final list = (json["notifications"] as List);
      modelData = NotificationModelData(
        notifications: List<Notification>.from(
          list.map((x) => Notification.fromJson(x)),
        ),
        pagination: Pagination(
          currentPage: 1,
          totalPages: 1,
          totalCount: list.length,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
    } else {
      modelData = NotificationModelData(
        notifications: [],
        pagination: Pagination(
          currentPage: 1,
          totalPages: 1,
          totalCount: 0,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
    }

    return NotificationModel(
      success: json["success"] == true || json["success"] == "true" || json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: modelData,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class NotificationModelData {
  List<Notification> notifications;
  Pagination pagination;

  NotificationModelData({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationModelData.fromJson(Map<String, dynamic> json) {
    List<Notification> notifs = [];
    if (json["notifications"] != null && json["notifications"] is List) {
      notifs = List<Notification>.from(
        (json["notifications"] as List).map((x) => Notification.fromJson(x)),
      );
    }
    Pagination pag = json["pagination"] != null && json["pagination"] is Map<String, dynamic>
        ? Pagination.fromJson(json["pagination"])
        : Pagination(
            currentPage: 1,
            totalPages: 1,
            totalCount: notifs.length,
            hasNextPage: false,
            hasPrevPage: false,
          );

    return NotificationModelData(
      notifications: notifs,
      pagination: pag,
    );
  }

  Map<String, dynamic> toJson() => {
        "notifications":
            List<dynamic>.from(notifications.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
      };
}

class Notification {
  final String id;
  final String type;
  final String title;
  final String message;
  final NotificationData data;
  final bool isRead;
  final bool isActive;
  final String? createdBy;
  final String? userId;
  final bool? isGeneralNotification;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? readAt;
  final DateTime? expiresAt;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.isActive,
    this.createdBy,
    this.userId,
    this.isGeneralNotification,
    required this.createdAt,
    required this.updatedAt,
    this.readAt,
    this.expiresAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['_id'] ?? '',
        type: json['type'] ?? '',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        data: NotificationData.fromJson(json['data']),
        isRead: json['isRead'] ?? false,
        isActive: json['isActive'] ?? false,
        createdBy: json['createdBy'],
        userId: json['userId'],
        isGeneralNotification: json['isGeneralNotification'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        readAt:
            json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "type": type,
        "title": title,
        "message": message,
        "data": data.toJson(),
        "isRead": isRead,
        "isActive": isActive,
        "createdBy": createdBy,
        "readAt": readAt,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        // "__v": v,
        "expiresAt": expiresAt,
        "isGeneralNotification": isGeneralNotification,
      };
}

enum CreatedBy { THE_67715653128_E45_A0_B089_EC0_E }

final createdByValues = EnumValues(
    {"67715653128e45a0b089ec0e": CreatedBy.THE_67715653128_E45_A0_B089_EC0_E});

class NotificationData {
  final String? workOrderId;
  final String? workOrderNumber;
  final String? assignedBy;

  final List<String>? assetIds;
  final int? assetCount;
  final String? syncedBy;
  final String? syncedByUsername;

  NotificationData({
    this.workOrderId,
    this.workOrderNumber,
    this.assignedBy,
    this.assetIds,
    this.assetCount,
    this.syncedBy,
    this.syncedByUsername,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      workOrderId: json['workOrderId'],
      workOrderNumber: json['workOrderNumber'],
      assignedBy: json['assignedBy'],
      assetIds: (json['assetIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      assetCount: json['assetCount'],
      syncedBy: json['syncedBy'],
      syncedByUsername: json['syncedByUsername'],
    );
  }
  Map<String, dynamic> toJson() => {
        "workOrderId": workOrderId,
        "workOrderNumber": workOrderNumber,
        "assignedBy": assignedBy,
        "assetIds":
            assetIds == null ? [] : List<dynamic>.from(assetIds!.map((x) => x)),
        "assetCount": assetCount,
        "syncedBy": syncedBy,
        "syncedByUsername": syncedByUsername,
      };
}

enum AssignedBy { SYSTEM, TEST_ONSHORE }

final assignedByValues = EnumValues(
    {"System": AssignedBy.SYSTEM, "Test-onshore": AssignedBy.TEST_ONSHORE});

enum Title { ASSET_SYNC_COMPLETED, NEW_WORK_ORDER_ASSIGNED }

final titleValues = EnumValues({
  "Asset Sync Completed": Title.ASSET_SYNC_COMPLETED,
  "New Work Order Assigned": Title.NEW_WORK_ORDER_ASSIGNED
});

enum Type { SYNC_DATA_ALERT, WORK_ORDER_ASSIGNMENT }

final typeValues = EnumValues({
  "syncDataAlert": Type.SYNC_DATA_ALERT,
  "workOrderAssignment": Type.WORK_ORDER_ASSIGNMENT
});

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
    );
  }
  Map<String, dynamic> toJson() => {
        "currentPage": currentPage,
        "totalPages": totalPages,
        "totalCount": totalCount,
        "hasNextPage": hasNextPage,
        "hasPrevPage": hasPrevPage,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
