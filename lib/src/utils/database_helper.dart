// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../features/login/data/models/user_login.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  Database? _database;
  Database? _dropdownDatabase;
  Database? _workOrderDatabase;
  Database? _onshoreDatabase;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> get dropdownDatabase async {
    if (_dropdownDatabase != null) return _dropdownDatabase!;
    _dropdownDatabase = await initDropDownDB();
    return _dropdownDatabase!;
  }

  Future<Database> get workOrderDatabase async {
    if (_workOrderDatabase != null) return _workOrderDatabase!;
    _workOrderDatabase = await initWorkOrderDB();
    return _workOrderDatabase!;
  }

  Future<Database> get onshoreDatabase async {
    if (_onshoreDatabase != null) return _onshoreDatabase!;
    _onshoreDatabase = await initOnshoreDB();
    return _onshoreDatabase!;
  }

  Future<String> _getDbPath(String dbName) async {
    if (kIsWeb) {
      return dbName;
    } else {
      final dbPath = await getDatabasesPath();
      return join(dbPath, dbName);
    }
  }

  Future<Database> _initDB() async {
    final path = await _getDbPath('auth.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE user_details (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT UNIQUE,
          firstName TEXT,
          lastName TEXT,
          email TEXT,
          userRole TEXT,
          signature TEXT,
          userName TEXT,
          password TEXT,   
          accessToken TEXT,
          refreshToken TEXT
        )
      ''');
      },
    );
  }

  Future<Database> dataSyncAuditTrial() async {
    final path = await _getDbPath('auth.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mobile_sync_details (
            sync_id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT UNIQUE,
            created_time DATETIME NOT NULL DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')), ,
            ex_register_data_count INTEGER,
            functional_data_area_count INTEGER,
            ex_inspection_data_count INTEGER,
            Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  Future<Database> initDropDownDB() async {
    final path = await _getDbPath('dropdown.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE all_dropdown (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          locationDropDown JSON,
          exResiterDropDown JSON,
          created_by TEXT,
          created_at TEXT,
          updated_by TEXT,
          updated_at TEXT,
          lastSync TEXT,
          syncFlag INTEGER DEFAULT 0
        )
      ''');

        await db.execute('''
        CREATE TABLE inspection_checklist (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          checkLists JSON,
          checkListDetails JSON,
          created_at TEXT,
          updated_at TEXT,
          created_by TEXT,
          updated_by TEXT,
          lastSync TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE file_upload (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_of TEXT NOT NULL,
        file_name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        created_by TEXT,
        updated_by TEXT
        )
      ''');

        await db.execute('''
          CREATE TABLE image_upload (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_path TEXT NOT NULL,
            image_type TEXT NOT NULL,
            file_of TEXT NOT NULL,
            image_name TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT,
            created_by TEXT,
            updated_by TEXT
          )
        ''');
      },
    );
  }

  Future<Database> initWorkOrderDB() async {
    final path = await _getDbPath('workOrder.db');
    return await openDatabase(
      path,
      version: 1,
      singleInstance: true,
      onConfigure: (db) async {
        // ❗ MUST be rawQuery
        await db.rawQuery('PRAGMA journal_mode=DELETE;');

        // ✔ Safe with execute
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE workOrder_assets (
          id TEXT PRIMARY KEY,
          work_order_json JSON,
          created_by TEXT,
          updated_by TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE work_order_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          work_order_table_json JSON,
          created_by TEXT,
          updated_by TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE functional_area (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          functional_area_json JSON,
          created_by TEXT,
          updated_by TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE exregister_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exregister_json JSON,
          created_by TEXT,
          updated_by TEXT,
          asset_id TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE mobile_sync_device (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assetId TEXT NOT NULL,
        functionality TEXT NOT NULL,
        functionality_api_response_id TEXT NOT NULL,
        status INTEGER NOT NULL,  
        lastSync DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
        created_by TEXT NOT NULL,
        updated_by TEXT NOT NULL
        )
      ''');
      },
    );
  }

  // datetime(CURRENT_TIMESTAMP, '-1 day', 'localtime')
  Future<Database> initOnshoreDB() async {
    final path = await _getDbPath('onshore.db');
    return await openDatabase(
      path,
      version: 1,
      singleInstance: true,
      onConfigure: (db) async {
        // ❗ MUST be rawQuery
        await db.rawQuery('PRAGMA journal_mode=DELETE;');

        // ✔ Safe with execute
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE all_dropdown_onshore (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          locationDropDown JSON,
          exResiterDropDown JSON,
          created_by TEXT,
          created_at TEXT,
          updated_by TEXT,
          updated_at TEXT,
          lastSync TEXT,
          syncFlag INTEGER DEFAULT 0
        )
      ''');

        await db.execute('''
        CREATE TABLE inspection_checklist_onshore (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          checkLists JSON,
          checkListDetails JSON,
          created_at TEXT,
          updated_at TEXT,
          created_by TEXT,
          updated_by TEXT,
          lastSync TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE workOrder_assets_onshore (
          id TEXT PRIMARY KEY,
          work_order_json JSON,
          created_by TEXT,
          updated_by TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE work_order_table_onshore (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          work_order_table_onshore_json JSON,
          created_by TEXT,
          updated_by TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE functional_area_onshore (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          functional_area_json JSON,
          created_by TEXT,
          updated_by TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE exregister_table_onshore (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exregister_json JSON,
          created_by TEXT,
          updated_by TEXT,
          asset_id TEXT,
          created_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
          updated_date DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime'))
        )
      ''');

        await db.execute('''
        CREATE TABLE file_upload_onshore (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_of TEXT NOT NULL,
        file_name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        created_by TEXT,
        updated_by TEXT
        )
      ''');

        await db.execute('''
          CREATE TABLE image_upload_onshore (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_path TEXT NOT NULL,
            image_type TEXT NOT NULL,
            file_of TEXT NOT NULL,
            image_name TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT,
            created_by TEXT,
            updated_by TEXT
          )
        ''');

        await db.execute('''
        CREATE TABLE mobile_sync_device_onshore (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assetId TEXT NOT NULL,
        functionality TEXT NOT NULL,
        functionality_api_response_id TEXT NOT NULL,
        status INTEGER NOT NULL,  
        lastSync DATETIME DEFAULT (datetime(CURRENT_TIMESTAMP, 'localtime')),
        created_by TEXT NOT NULL,
        updated_by TEXT NOT NULL
        )
      ''');
      },
    );
  }

  Future<void> saveUser(UserDetails user) async {
    final db = await database;
    await db.insert(
      'user_details',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(UserDetails user) async {
    final db = await database;
    await db.update(
      'user_details',
      user.toJson(),
      where: 'userId = ?',
      whereArgs: [user.userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSessionTokens(
    String userId,
    String accessToken,
    String refreshToken,
  ) async {
    final db = await database;
    await db.update(
      'user_details',
      {'accessToken': accessToken, 'refreshToken': refreshToken},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<UserDetails?> getLoggedInUser() async {
    final db = await database;
    final result = await db.query('user_details', limit: 1);
    if (result.isNotEmpty) {
      return UserDetails.fromJson(result.first);
    }
    return null;
  }

  Future<UserDetails?> getLoggedInUserByUserId(String userId) async {
    final db = await database;
    final result = await db.query(
      'user_details',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserDetails.fromJson(result.first);
    }
    return null;
  }

  Future<UserDetails?> getLoggedInUserByCredentials(UserLogin userLogin) async {
    final db = await database;
    final result = await db.query(
      'user_details',
      where: 'username = ? AND password = ?',
      whereArgs: [userLogin.username, userLogin.password],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserDetails.fromJson(result.first);
    }
    return null;
  }

  Future<void> clearUserSession(String userId) async {
    final db = await database;
    await db.update(
      'user_details',
      {'accessToken': null, 'refreshToken': null},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> saveDropDownData(
    Map<String, dynamic> data, {
    bool isSynced = true,
  }) async {
    final db = await initDropDownDB();
    await db.insert(
        'all_dropdown',
        {
          'locationDropDown': jsonEncode(data['locationDropDown']),
          'exResiterDropDown': jsonEncode(data['exResiterDropDown']),
          'created_by': data['created_by'],
          'updated_by': data['updated_by'],
          'updated_at': data['updated_at'],
          'lastSync': DateTime.now().toIso8601String(),
          'syncFlag': isSynced ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getDropDownData() async {
    final db = await initDropDownDB();
    final result =
        await _safeBatchQuery(db, 'all_dropdown', limit: 1, orderBy: 'id DESC');
    if (result.isNotEmpty) {
      final locationDropDown =
          jsonDecode(result.first['locationDropDown'] as String)
              as List<dynamic>;
      final exResiterDropDown =
          jsonDecode(result.first['exResiterDropDown'] as String)
              as List<dynamic>;
      return {
        'status': true,
        'message': 'Data successfully!',
        'result': {
          'locationDropDown': locationDropDown,
          'exResiterDropDown': exResiterDropDown,
        },
        'created_by': result.first['created_by'],
        'created_at': result.first['created_at'],
        'updated_by': result.first['updated_by'],
        'updated_at': result.first['updated_at'],
        'lastSync': result.first['lastSync'],
        'syncFlag': result.first['syncFlag'],
      };
    }
    return null;
  }

  Future<void> saveWorkOrderAsset(Map<String, dynamic> workOrder) async {
    final db = await workOrderDatabase;

    /// --------------------------------------------------
    /// EXTRACT CORE DATA
    /// --------------------------------------------------
    final Map<String, dynamic> workOrderJson =
        workOrder['work_order_json'] as Map<String, dynamic>;

    final Map<String, dynamic> assetJson =
        workOrderJson['assets'] as Map<String, dynamic>; // ✅ SINGLE ASSET

    final String workOrderId = workOrderJson['_id'].toString();
    final String assetId = assetJson['_id'].toString();

    /// --------------------------------------------------
    /// CLEAN WORK ORDER (REMOVE ASSET)
    /// --------------------------------------------------
    final Map<String, dynamic> cleanWorkOrderJson =
        Map<String, dynamic>.from(workOrderJson);
    cleanWorkOrderJson.remove('assets');

    /// --------------------------------------------------
    /// BUILD SMALL SAFE JSON
    /// --------------------------------------------------
    final Map<String, dynamic> dbJson = {
      'workOrder': cleanWorkOrderJson,
      'asset': assetJson, // ✅ ONE ASSET ONLY
    };

    /// --------------------------------------------------
    /// INSERT / UPDATE (ONE ASSET = ONE ROW)
    /// --------------------------------------------------
    await db.insert(
      'workOrder_assets',
      {
        'id': assetId, // ✅ IMPORTANT FIX
        'work_order_json': jsonEncode(dbJson),
        'created_by': workOrder['created_by'],
        'updated_by': workOrder['updated_by'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    /// ==================================================
    /// BELOW LOGIC KEPT SAME (WORK ORDER TABLE)
    /// ==================================================
    final workOrderTableData = {
      'work_order_table_json': jsonEncode({
        'work_order': {
          '_id': workOrderId,
          'woNumber': workOrderJson['woNumber'],
          'woType': workOrderJson['woType'],
          'discipline': workOrderJson['discipline'] ?? '',
          'woDate': workOrderJson['woDate'] ?? '',
          'department': workOrderJson['department'] ?? '',
          'maintanaceType': workOrderJson['maintanaceType'] ?? '',
          'description': workOrderJson['description'] ?? '',
          'startDate': workOrderJson['startDate'] ?? '',
          'endDate': workOrderJson['endDate'].toString(),
          'duration': workOrderJson['duration'] ?? '',
          'permitType': workOrderJson['permitType'] ?? '',
          'priority': workOrderJson['priority'] ?? '',
          'status': workOrderJson['status'],
          'remark': workOrderJson['remark'],
          'progress': workOrderJson['progress'],
          'currentStatus': workOrderJson['currentStatus'] ?? '',
        },
      }),
      'created_by': workOrder['created_by'],
      'updated_by': workOrder['updated_by'],
    };

    final existingWordOrderData = await db.query(
      'work_order_table',
      columns: ['id'],
      where: 'work_order_table_json LIKE ?',
      whereArgs: ['%"_id":"$workOrderId"%'],
    );

    if (existingWordOrderData.isNotEmpty) {
      await db.update(
        'work_order_table',
        workOrderTableData,
        where: 'id = ?',
        whereArgs: [existingWordOrderData.first['id']],
      );
    } else {
      await db.insert(
        'work_order_table',
        workOrderTableData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    /// ==================================================
    /// FUNCTIONAL AREA (UNCHANGED)
    /// ==================================================
    final assetFuncationJson = assetJson;
    final locationId = assetFuncationJson['locationId'];

    final functionalAreaData = {
      'functional_area_json': jsonEncode({
        'location': {
          'locationId': assetFuncationJson['locationId'],
          'location': assetFuncationJson['location'],
          'areaClassDrawAttach':
              assetFuncationJson['areaClassDrawAttach'] ?? [],
          'areaClassDrawNo': assetFuncationJson['areaClassDrawNo'] ?? [],
          'areaClassDrawAttachOrgName':
              assetFuncationJson['areaClassDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawAttachOrgName':
              assetFuncationJson['eqpmtLytDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawAttach': assetFuncationJson['eqpmtLytDrawAttach'] ?? [],
          'eqpmtLytDrawNo': assetFuncationJson['eqpmtLytDrawNo'] ?? [],
          'area': assetFuncationJson['area'] ?? '',
          'deckLevel': assetFuncationJson['deckLevel'] ?? '',
          'subArea': assetFuncationJson['subArea'] ?? '',
          'zone': assetFuncationJson['zone'] ?? '',
          'locationGasGroup': assetFuncationJson['locationGasGroup'] ?? [],
          'locationTClass': assetFuncationJson['locationTClass'] ?? [],
          'locationIpRating': assetFuncationJson['locationIpRating'] ?? [],
          'tAmbient': assetFuncationJson['locationTAmbient'] ?? '',
          'locationLongitude': assetFuncationJson['locationLongitude'] ?? '',
          'locationLatitude': assetFuncationJson['locationLatitude'] ?? '',
          'isActive': assetFuncationJson['isActive'] ?? '',
          'areaStatus': assetFuncationJson['areaStatus'] ?? '',
          'isDuplicate': false,
        },
      }),
      'created_by': workOrder['created_by'],
      'updated_by': workOrder['updated_by'],
    };

    // final locationId = assetFuncationJson['locationId'];
    final existingFunctionalArea = await db.query(
      'functional_area',
      columns: ['id'],
      where: 'functional_area_json LIKE ?',
      whereArgs: ['%"locationId":"$locationId"%'],
    );
    if (existingFunctionalArea.isNotEmpty) {
      await db.update(
        'functional_area',
        functionalAreaData,
        where: 'id = ?',
        whereArgs: [existingFunctionalArea.first['id']],
      );
    } else {
      await db.insert(
        'functional_area',
        functionalAreaData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    final exRegisterData = {
      'exregister_json': jsonEncode({
        'asset': {
          '_id': assetFuncationJson['_id'] ?? '',
          'locationId': assetFuncationJson['locationId'],
          'location': assetFuncationJson['location'],
          'area': assetFuncationJson['area'] ?? '',
          'zone': assetFuncationJson['zone'] ?? '',
          'areaClassDrawAttach':
              assetFuncationJson['areaClassDrawAttach'] ?? [],
          'areaClassDrawNo': assetFuncationJson['areaClassDrawNo'] ?? [],
          'areaClassDrawAttachOrgName':
              assetFuncationJson['areaClassDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawAttachOrgName':
              assetFuncationJson['eqpmtLytDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawAttach': assetFuncationJson['eqpmtLytDrawAttach'] ?? [],
          'locationGasGroup': assetFuncationJson['locationGasGroup'] ?? [],
          'locationTClass': assetFuncationJson['locationTClass'] ?? [],
          'locationIpRating': assetFuncationJson['locationIpRating'] ?? [],
          'eqpmtLytDrawNo': assetFuncationJson['eqpmtLytDrawNo'] ?? [],
          'deckLevel': assetFuncationJson['deckLevel'] ?? '',
          'locationLongitude': assetFuncationJson['locationLongitude'] ?? '',
          'locationLatitude': assetFuncationJson['locationLatitude'] ?? '',
          'eqpmtLongitude': assetFuncationJson['eqpmtLongitude'] ?? '',
          'eqpmtLatitude': assetFuncationJson['eqpmtLatitude'] ?? '',
          'isActive': assetFuncationJson['isActive'] ?? '',
          'eqpmtCatg': assetFuncationJson['eqpmtCatg'] ?? '',
          'description': assetFuncationJson['description'] ?? '',
          'atexCatg': assetFuncationJson['atexCatg'] ?? [],
          'epl': assetFuncationJson['epl'] ?? [],
          'protectionType': assetFuncationJson['protectionType'] ?? [],
          'subArea': assetFuncationJson['subArea'] ?? '',
          'rfidRef': assetFuncationJson['rfidRef'] ?? '',
          'gpsCord': assetFuncationJson['gpsCord'] ?? '',
          'eqpmtTag': assetFuncationJson['eqpmtTag'] ?? '',
          'circuitId': assetFuncationJson['circuitId'] ?? '',
          'cableId': assetFuncationJson['cableId'] ?? '',
          'equipmentCategory': assetFuncationJson['equipmentCategory'] ?? '',
          'manufacturer': assetFuncationJson['manufacturer'] ?? '',
          'type': assetFuncationJson['type'] ?? '',
          'serialNumber': assetFuncationJson['serialNumber'] ?? '',
          'protectionStd': assetFuncationJson['protectionStd'] ?? '',
          'equipmentGasGroup': assetFuncationJson['equipmentGasGroup'] ?? [],
          'equipmentTClass': assetFuncationJson['equipmentTClass'] ?? [],
          'equipmentIpRating': assetFuncationJson['equipmentIpRating'] ?? [],
          'certfnBody': assetFuncationJson['certfnBody'] ?? '',
          'locationTAmbient': assetFuncationJson['locationTAmbient'] ?? '',
          'certfnNo': assetFuncationJson['certfnNo'] ?? '',
          'tAmbient': assetFuncationJson['tAmbient'] ?? '',
          'inspectionSignOff': assetFuncationJson['inspectionSignOff'] ?? '',
          'repairSignOff': assetFuncationJson['repairSignOff'] ?? '',
          'tAmbientEquip': assetFuncationJson['tAmbientEquip'] ?? '',
          'specialCond': assetFuncationJson['specialCond'] ?? '',
          'oracleId': assetFuncationJson['oracleId'] ?? '',
          'yesNoSelection': assetFuncationJson['yesNoSelection'] ?? {},
          'checkList': assetFuncationJson['checkList'] ?? [],
          'inspectedBy': assetFuncationJson['inspectedBy'] ?? '',
          'inspectedDate': assetFuncationJson['inspectedDate'] ?? '',
          'repairedBy': assetFuncationJson['repairedBy'] ?? '',
          'repairedDate': assetFuncationJson['repairedDate'] ?? '',
          'faultyItems': assetFuncationJson['faultyItems'] ?? '',
          'repairPriority': assetFuncationJson['repairPriority'] ?? '',
          'inspectionStatus': assetFuncationJson['inspectionStatus'] ?? '',
          'defectOverallCondition':
              assetFuncationJson['defectOverallCondition'] ?? '',
          'defectIsolation': assetFuncationJson['defectIsolation'] ?? '',
          'defectOtherRequirements':
              assetFuncationJson['defectOtherRequirements'] ?? [],
          'remarks': assetFuncationJson['remarks'] ?? '',
          'dataSheet': assetFuncationJson['dataSheet'] ?? '',
          'dataSheetNo': assetFuncationJson['dataSheetNo'] ?? '',
          'dataSheetOrgName': assetFuncationJson['dataSheetOrgName'] ?? '',
          'defectivePhoto1': assetFuncationJson['defectivePhoto1'] ?? '',
          'defectivePhoto1OrgName':
              assetFuncationJson['defectivePhoto1OrgName'] ?? '',
          'defectivePhoto2': assetFuncationJson['defectivePhoto2'] ?? '',
          'defectivePhoto2OrgName':
              assetFuncationJson['defectivePhoto2OrgName'] ?? '',
          'defectivePhoto3': assetFuncationJson['defectivePhoto3'] ?? '',
          'defectivePhoto3OrgName':
              assetFuncationJson['defectivePhoto3OrgName'] ?? '',
          'defectivePhoto4': assetFuncationJson['defectivePhoto4'] ?? '',
          'defectivePhoto4OrgName':
              assetFuncationJson['defectivePhoto4OrgName'] ?? '',
          'defectivePhoto5': assetFuncationJson['defectivePhoto5'] ?? '',
          'defectivePhoto5OrgName':
              assetFuncationJson['defectivePhoto5OrgName'] ?? '',
          'defectivePhoto6': assetFuncationJson['defectivePhoto6'] ?? '',
          'defectivePhoto6OrgName':
              assetFuncationJson['defectivePhoto6OrgName'] ?? '',
          'materials': assetFuncationJson['materials'] ?? [],
          'existingFaults': assetFuncationJson['existingFaults'] ?? '',
          'correctiveDefectCategory':
              assetFuncationJson['correctiveDefectCategory'] ?? '',
          'currentStatus': assetFuncationJson['currentStatus'] ?? '',
          'correctiveOverallCondition':
              assetFuncationJson['correctiveOverallCondition'] ?? '',
          'correctiveisolation':
              assetFuncationJson['correctiveisolation'] ?? '',
          'correctiveOtherRequirements':
              assetFuncationJson['correctiveOtherRequirements'] ?? '',
          'repairsDone': assetFuncationJson['repairsDone'] ?? '',
          'rbiStrategy':
              (assetFuncationJson['rbiStrategy'] as Map<String, dynamic>?) ??
                  {},
          'additionalInfoForRepairs':
              assetFuncationJson['additionalInfoForRepairs'] ?? '',
          'remarksIfAny': assetFuncationJson['remarksIfAny'] ?? '',
          'supplementaryMaterialReq':
              assetFuncationJson['supplementaryMaterialReq'] ?? [],
          'defectCertificationOrgName':
              assetFuncationJson['defectCertificationOrgName'] ?? '',
          'defectCertificationNo':
              assetFuncationJson['defectCertificationNo'] ?? '',
          'defectCertificationAttach':
              assetFuncationJson['defectCertificationAttach'] ?? '',
          'correctiveCertificationNo':
              assetFuncationJson['correctiveCertificationNo'] ?? '',
          'correctiveCertificationOrgName':
              assetFuncationJson['correctiveCertificationOrgName'] ?? '',
          'correctiveCertificationAttach':
              assetFuncationJson['correctiveCertificationAttach'] ?? '',
          'inspectionChecklistType':
              assetFuncationJson['inspectionChecklistType'] ?? [],
          'inspectionType': assetFuncationJson['inspectionType'] ?? '',
          'inspectionGrade': assetFuncationJson['inspectionGrade'] ?? '',
          'equipmentEquipmentType':
              assetFuncationJson['equipmentEquipmentType'] ?? '',
          'correctivePhoto1': assetFuncationJson['correctivePhoto1'] ?? '',
          'correctivePhoto1OrgName':
              assetFuncationJson['correctivePhoto1OrgName'] ?? '',
          'correctivePhoto2': assetFuncationJson['correctivePhoto2'] ?? '',
          'correctivePhoto2OrgName':
              assetFuncationJson['correctivePhoto2OrgName'] ?? '',
          'correctivePhoto3': assetFuncationJson['correctivePhoto3'] ?? '',
          'correctivePhoto3OrgName':
              assetFuncationJson['correctivePhoto3OrgName'] ?? '',
          'correctivePhoto4': assetFuncationJson['correctivePhoto4'] ?? '',
          'correctivePhoto4OrgName':
              assetFuncationJson['correctivePhoto4OrgName'] ?? '',
          'correctivePhoto5': assetFuncationJson['correctivePhoto5'] ?? '',
          'correctivePhoto5OrgName':
              assetFuncationJson['correctivePhoto5OrgName'] ?? '',
          'correctivePhoto6': assetFuncationJson['correctivePhoto6'] ?? '',
          'correctivePhoto6OrgName':
              assetFuncationJson['correctivePhoto6OrgName'] ?? '',
          'primaryId': assetFuncationJson['_id'] ?? '',
          'defectDefectCategory':
              assetFuncationJson['defectDefectCategory'] ?? '',
          'repairDuration': assetFuncationJson['repairDuration'] ?? '',
          'repairTimeEstimate': assetFuncationJson['repairTimeEstimate'] ?? '',
          'isDuplicate': false,
          'areaStatus': assetFuncationJson['areaStatus'] ?? '',
        },
      }),
      'created_by': workOrder['created_by'],
      'updated_by': workOrder['updated_by'],
    };
    final assetIdData = assetFuncationJson['_id'];
    final existingExRegister = await db.query(
      'exregister_table',
      columns: ['id'],
      where: 'exregister_json LIKE ? AND exregister_json LIKE ?',
      whereArgs: ['%"locationId":"$locationId"%', '%"_id":"$assetIdData"%'],
    );

    int recordId;
    if (existingExRegister.isNotEmpty) {
      recordId = existingExRegister.first['id'] as int;
      final updatedJson = jsonDecode(exRegisterData['exregister_json']!);
      updatedJson['asset']['primaryId'] = recordId;
      exRegisterData['exregister_json'] = jsonEncode(updatedJson);
      await db.update(
        'exregister_table',
        exRegisterData,
        where: 'id = ?',
        whereArgs: [recordId],
      );
    } else {
      recordId = await db.insert(
        'exregister_table',
        exRegisterData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final updatedJson = jsonDecode(exRegisterData['exregister_json']!);
      updatedJson['asset']['primaryId'] = recordId;
      exRegisterData['exregister_json'] = jsonEncode(updatedJson);
      await db.update(
        'exregister_table',
        exRegisterData,
        where: 'id = ?',
        whereArgs: [recordId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getWorkOrderAssets() async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(db, 'workOrder_assets');
  }

  Future<String?> saveFunctionalArea(
    Map<String, dynamic> functionalArea,
  ) async {
    final db = await workOrderDatabase;
    int newId = await db.insert(
      'functional_area',
      functionalArea,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    String functionalAreaJson =
        functionalArea['functional_area_json'] as String;
    Map<String, dynamic> decodedJson = jsonDecode(functionalAreaJson);

    String? locationId;
    if (decodedJson.containsKey('location')) {
      Map<String, dynamic> locationMap = decodedJson['location'];
      locationMap['locationId'] = newId.toString();
      locationId = locationMap['locationId'];
    }

    functionalArea['functional_area_json'] = jsonEncode(decodedJson);
    await db.update(
      'functional_area',
      {'functional_area_json': functionalArea['functional_area_json']},
      where: 'id = ?',
      whereArgs: [newId],
    );

    return locationId;
  }

  Future<void> updateFunctionalAreaAndExRegisters(
    Map<String, dynamic> updatedFunctionalArea,
  ) async {
    final db = await workOrderDatabase;
    final updatedFunctionalAreaJson =
        updatedFunctionalArea['functional_area_json'] as String;
    final updatedFunctionalAreaData =
        jsonDecode(updatedFunctionalAreaJson) as Map<String, dynamic>;
    final updatedLocationId =
        updatedFunctionalAreaData['location']?['locationId'];

    if (updatedLocationId == null) {
      throw ArgumentError(
        'Invalid functional_area_json: locationId is missing',
      );
    }

    await db.update(
      'functional_area',
      updatedFunctionalArea,
      where: 'functional_area_json LIKE ? OR id = ?',
      whereArgs: [
        '%"locationId":"$updatedLocationId"%',
        int.tryParse(updatedLocationId) ?? -1,
      ],
    );

    final relatedExRegisters = await _safeBatchQuery(
      db,
      'exregister_table',
      where: 'exregister_json LIKE ?',
      whereArgs: ['%"locationId":"$updatedLocationId"%'],
    );

    final fieldsToUpdate = [
      'location',
      'areaClassDrawNo',
      'areaClassDrawAttach',
      'areaClassDrawAttachOrgName',
      'eqpmtLytDrawNo',
      'eqpmtLytDrawAttach',
      'eqpmtLytDrawAttachOrgName',
      'subArea',
      'area',
      'locationLatitude',
      'locationLongitude',
      'zone',
      'locationGasGroup',
      'locationTClass',
      'locationIpRating',
      'deckLevel',
      'isActive',
    ];

    for (final exRegister in relatedExRegisters) {
      final exRegisterJsonString = exRegister['exregister_json'] as String;
      final exRegisterData =
          jsonDecode(exRegisterJsonString) as Map<String, dynamic>;

      if (exRegisterData['asset']?['locationId'] == updatedLocationId) {
        final updatedExRegisterData = Map<String, dynamic>.from(exRegisterData);
        final asset = updatedExRegisterData['asset'] as Map<String, dynamic>;

        for (final field in fieldsToUpdate) {
          if (updatedFunctionalAreaData['location'] != null &&
              updatedFunctionalAreaData['location'].containsKey(field)) {
            asset[field] = updatedFunctionalAreaData['location'][field];
          } else if (updatedFunctionalAreaData.containsKey(field)) {
            asset[field] = updatedFunctionalAreaData[field];
          }
        }

        updatedExRegisterData['exregister_json'] = jsonEncode(
          updatedExRegisterData,
        );

        final updatedExRegisterJsonString = jsonEncode(updatedExRegisterData);

        await db.update(
          'exregister_table',
          {'exregister_json': updatedExRegisterJsonString},
          where: 'id = ?',
          whereArgs: [exRegister['id']],
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getFunctionalArea() async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(db, 'functional_area');
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaByOffset(
    int skip,
    int limit,
  ) async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(
      db,
      'functional_area',
      orderBy: 'id DESC',
      limit: limit,
      offset: skip,
    );
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaBySorting(
    String sortField,
    String sortOrder,
  ) async {
    final db = await workOrderDatabase;
    final normalizedSortOrder =
        sortOrder.toLowerCase() == "descending" ? "DESC" : "ASC";
    String query = '''
    SELECT * FROM functional_area
    ORDER BY json_extract(functional_area_json, '\$.location.$sortField') $normalizedSortOrder
  ''';
    return await _safeBatchRawQuery(db, query);
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaData() async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(db, 'functional_area');
  }

  Future<Map<String, dynamic>?> getFunctionalAreaById(String locationId) async {
    final db = await workOrderDatabase;
    final results = await _safeBatchQuery(
      db,
      'functional_area',
      where: 'functional_area_json LIKE ?',
      whereArgs: ['%"locationId":"$locationId"%'],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<String> saveExRegister(Map<String, dynamic> exRegisterJson) async {
    final db = await workOrderDatabase;
    int newId = await db.insert(
      'exregister_table',
      exRegisterJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    String exregisterJsonString = exRegisterJson['exregister_json'] as String;
    Map<String, dynamic> decodedJson = jsonDecode(exregisterJsonString);
    Map<String, dynamic> assetMap = (decodedJson['asset'] is Map)
        ? Map<String, dynamic>.from(decodedJson['asset'] as Map)
        : Map<String, dynamic>.from(decodedJson);
    assetMap['_id'] = newId.toString();
    assetMap['primaryId'] = newId;
    assetMap['id'] = newId.toString();
    final updatedJsonString = jsonEncode({'asset': assetMap});
    await db.update(
      'exregister_table',
      {'exregister_json': updatedJsonString},
      where: 'id = ?',
      whereArgs: [newId],
    );
    return newId.toString();
  }

  Future<List<Map<String, dynamic>>> getExRegister() async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(db, 'exregister_table');
  }

  Future<List<Map<String, dynamic>>> getExRegisterByOffset(
    int skip,
    int limit,
  ) async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(
      db,
      'exregister_table',
      orderBy: 'id DESC',
      limit: limit,
      offset: skip,
    );
  }

  Future<List<Map<String, dynamic>>> getFilterExRegisterOnshore(
    int skip,
    int limit,
  ) async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(
      db,
      'exregister_table_onshore',
      orderBy: 'id DESC',
      limit: limit,
      offset: skip,
    );
  }

  Future<List<Map<String, dynamic>>> getFilterExRegister(
    int skip,
    int limit,
  ) async {
    final db = await workOrderDatabase;
    return await _safeBatchQuery(
      db,
      'exregister_table',
      orderBy: 'id DESC',
      limit: limit,
      offset: skip,
    );
  }

  Future<List<Map<String, dynamic>>> getExRegisterBySorting(
    String sortField,
    String sortOrder,
  ) async {
    final db = await workOrderDatabase;
    final normalizedSortOrder =
        sortOrder.toLowerCase() == "descending" ? "DESC" : "ASC";
    String query;
    if (sortField == 'inspectionStatus' || sortField == 'currentStatus') {
      final sortOrderValues =
          sortOrder.split(',').map((value) => value.trim()).toList();
      final caseStatements = <String>[];
      int caseIndex = 1;
      for (final value in sortOrderValues) {
        caseStatements.add(
          "WHEN json_extract(exregister_json, '\$.asset.$sortField') = '$value' THEN $caseIndex",
        );
        caseIndex++;
      }
      caseStatements.add(
        "WHEN json_extract(exregister_json, '\$.asset.$sortField') IS NULL OR "
        "TRIM(json_extract(exregister_json, '\$.asset.$sortField')) = '' THEN $caseIndex",
      );
      caseIndex++;
      caseStatements.add("ELSE $caseIndex");
      query = '''
      SELECT * FROM exregister_table
      ORDER BY 
        CASE 
          ${caseStatements.join('\n')}
        END $normalizedSortOrder
    ''';
    } else {
      query = '''
      SELECT * FROM exregister_table
      ORDER BY 
        CASE 
          WHEN json_extract(exregister_json, '\$.asset.$sortField') IS NULL OR 
               TRIM(json_extract(exregister_json, '\$.asset.$sortField')) = '' THEN ${sortOrder.toLowerCase() == "ascending" ? 0 : 1}
          ELSE ${sortOrder.toLowerCase() == "ascending" ? 1 : 0}
        END ASC, 
        CASE 
          WHEN json_extract(exregister_json, '\$.asset.$sortField') GLOB '[0-9]*' THEN 
            CAST(json_extract(exregister_json, '\$.asset.$sortField') AS INTEGER)
          ELSE 
            LOWER(json_extract(exregister_json, '\$.asset.$sortField'))
        END $normalizedSortOrder
    ''';
    }
    return await _safeBatchRawQuery(db, query);
  }

  Future<Map<String, dynamic>?> getExRegisterById(String assetId) async {
    final db = await workOrderDatabase;
    final results = await _safeBatchQuery(db, 'exregister_table');
    for (final row in results) {
      if (row['id']?.toString() == assetId) {
        return row;
      }
    }
    for (final row in results) {
      final exRegisterJson = row['exregister_json'];
      if (exRegisterJson == null) continue;
      final jsonMap = (exRegisterJson is String)
          ? jsonDecode(exRegisterJson) as Map<String, dynamic>
          : exRegisterJson as Map<String, dynamic>;
      final asset = (jsonMap['asset'] is Map)
          ? jsonMap['asset'] as Map<String, dynamic>
          : jsonMap;
      if (asset['primaryId']?.toString() == assetId) {
        return row;
      }
    }
    for (final row in results) {
      final exRegisterJson = row['exregister_json'];
      if (exRegisterJson == null) continue;
      final jsonMap = (exRegisterJson is String)
          ? jsonDecode(exRegisterJson) as Map<String, dynamic>
          : exRegisterJson as Map<String, dynamic>;
      final asset = (jsonMap['asset'] is Map)
          ? jsonMap['asset'] as Map<String, dynamic>
          : jsonMap;
      if (asset['_id']?.toString() == assetId || asset['id']?.toString() == assetId) {
        return row;
      }
    }
    return null;
  }

  Future<int> deleteExRegisterById(String assetId, String id) async {
    final db = await workOrderDatabase;

    return await db.delete(
      'exregister_table',
      where: 'id = ?',
      whereArgs: [id.isNotEmpty ? id : assetId],
    );
  }

  Future<int> deleteExRegisterCollectionById(
    String assetId,
    List<String> assetIds,
  ) async {
    final db = await workOrderDatabase;

    final results = await _safeBatchQuery(db, 'exregister_table');

    final idsToDelete = results
        .where((row) {
          final exRegisterJson = row['exregister_json'] as String;
          final jsonMap = jsonDecode(exRegisterJson) as Map<String, dynamic>;
          final asset = jsonMap['asset'] ?? jsonMap;
          return assetIds.contains(asset['_id']?.toString()) ||
              assetIds.contains(asset['primaryId']?.toString()) ||
              assetIds.contains(row['id']?.toString());
        })
        .map((row) => row['id'])
        .toList();

    if (idsToDelete.isNotEmpty) {
      final placeholders = List.filled(idsToDelete.length, '?').join(', ');
      return await db.delete(
        'exregister_table',
        where: 'id IN ($placeholders)',
        whereArgs: idsToDelete,
      );
    }

    return 0;
  }

  Future<void> updateExRegisterById(Map<String, dynamic> exRegister) async {
    final db = await workOrderDatabase;
    final exRegisterJson = exRegister['exregister_json'] as String;
    final decodedJson = jsonDecode(exRegisterJson) as Map<String, dynamic>;
    final assetMap = (decodedJson['asset'] is Map)
        ? Map<String, dynamic>.from(decodedJson['asset'] as Map)
        : Map<String, dynamic>.from(decodedJson);

    final primaryId = assetMap['primaryId'] ?? decodedJson['primaryId'] ?? exRegister['id'] ?? assetMap['_id'];
    int? targetRowId = (primaryId != null) ? int.tryParse(primaryId.toString()) : null;

    if (targetRowId != null && targetRowId > 0) {
      assetMap['primaryId'] = targetRowId;
      assetMap['_id'] = targetRowId.toString();
      final updatedJsonString = jsonEncode({'asset': assetMap});
      final rowsUpdated = await db.update(
        'exregister_table',
        {
          'exregister_json': updatedJsonString,
          if (exRegister['updated_by'] != null) 'updated_by': exRegister['updated_by'],
          if (exRegister['updated_date'] != null) 'updated_date': exRegister['updated_date'],
        },
        where: 'id = ?',
        whereArgs: [targetRowId],
      );
      if (rowsUpdated > 0) return;
    }

    final assetId = assetMap['_id'] ?? assetMap['assetId'] ?? assetMap['id'];
    if (assetId != null && assetId.toString().isNotEmpty) {
      final allRows = await _safeBatchQuery(db, 'exregister_table');
      for (final row in allRows) {
        try {
          final rowJson = (row['exregister_json'] is String)
              ? jsonDecode(row['exregister_json'])
              : row['exregister_json'];
          final rowAsset = (rowJson is Map) ? (rowJson['asset'] ?? rowJson) : {};
          if (row['id']?.toString() == assetId.toString() ||
              rowAsset['primaryId']?.toString() == assetId.toString() ||
              rowAsset['_id']?.toString() == assetId.toString()) {
            final rowId = row['id'];
            assetMap['primaryId'] = rowId;
            assetMap['_id'] = rowId.toString();
            final updatedJsonString = jsonEncode({'asset': assetMap});
            await db.update(
              'exregister_table',
              {
                'exregister_json': updatedJsonString,
                if (exRegister['updated_by'] != null) 'updated_by': exRegister['updated_by'],
                if (exRegister['updated_date'] != null) 'updated_date': exRegister['updated_date'],
              },
              where: 'id = ?',
              whereArgs: [rowId],
            );
            return;
          }
        } catch (_) {}
      }
    }
  }

  Future<void> updateExRegisterByPrimaryId(
    Map<String, dynamic> exRegister,
  ) async {
    final db = await workOrderDatabase;
    final exRegisterJson = exRegister['exregister_json'];
    if (exRegisterJson == null) {
      throw ArgumentError('Invalid input: exregister_json is missing');
    }
    final decodedJson = jsonDecode(exRegisterJson) as Map<String, dynamic>;
    final asset = decodedJson['asset'];
    if (asset == null || asset['primaryId'] == null) {
      throw ArgumentError(
        'Invalid exregister_json: asset or asset primaryId is missing',
      );
    }
    final primaryId = asset['primaryId'];
    final rowsAffected = await db.update(
      'exregister_table',
      exRegister,
      where: 'id = ?',
      whereArgs: [primaryId],
    );
    if (rowsAffected == 0) {
      throw Exception('Ex Register with primaryId $primaryId not found');
    }
  }

  Future<void> saveInspectionChecklist(Map<String, dynamic> data) async {
    final db = await initDropDownDB();
    await db.insert(
        'inspection_checklist',
        {
          'checkLists': jsonEncode(data['checkLists']),
          'checkListDetails': jsonEncode(data['checkListDetails']),
          'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at': data['updated_at'] ?? DateTime.now().toIso8601String(),
          'created_by': data['created_by'],
          'updated_by': data['updated_by'],
          'lastSync': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getChecklistData() async {
    final db = await dropdownDatabase;
    List<Map<String, dynamic>> result =
        await _safeBatchQuery(db, 'inspection_checklist');
    if (result.isNotEmpty) {
      final checklist = result[0];
      return {
        'checkLists': jsonDecode(checklist['checkLists']),
        'checkListDetails': jsonDecode(checklist['checkListDetails']),
        'created_at': checklist['created_at'],
        'updated_at': checklist['updated_at'],
        'created_by': checklist['created_by'],
        'updated_by': checklist['updated_by'],
        'lastSync': checklist['lastSync'],
      };
    }
    return null;
  }

  Future<int> uploadFiles(Map<String, dynamic> data) async {
    final db = await initDropDownDB();
    return await db.insert(
      'file_upload',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> uploadImage(Map<String, dynamic> data) async {
    final db = await initDropDownDB();
    return await db.insert(
      'image_upload',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> saveMobileSyncServer(Map<String, dynamic> data) async {
    final db = await initWorkOrderDB();
    return await db.insert(
      'mobile_sync_device',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getMobileSyncServer(
    String assetId,
    String functionality,
  ) async {
    final db = await initWorkOrderDB();
    final result = await _safeBatchQuery(
      db,
      'mobile_sync_device',
      where: 'assetId = ? AND functionality = ?',
      whereArgs: [assetId, functionality],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMobileSyncServer(
    Map<String, dynamic> data,
    String assetId,
    String functionality,
  ) async {
    final db = await initWorkOrderDB();
    return await db.update(
      'mobile_sync_device',
      data,
      where: 'assetId = ? AND functionality = ?',
      whereArgs: [assetId, functionality],
    );
  }

  // OnShore Database

  Future<void> saveOnshoreDropDownData(
    Map<String, dynamic> data, {
    bool isSynced = true,
  }) async {
    final db = await initOnshoreDB();
    await db.insert(
        'all_dropdown_onshore',
        {
          'locationDropDown': jsonEncode(data['locationDropDown']),
          'exResiterDropDown': jsonEncode(data['exResiterDropDown']),
          'created_by': data['created_by'],
          'updated_by': data['updated_by'],
          'updated_at': data['updated_at'],
          'lastSync': DateTime.now().toIso8601String(),
          'syncFlag': isSynced ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getDropDownDataOnShore() async {
    final db = await initOnshoreDB();
    final result = await _safeBatchQuery(
      db,
      'all_dropdown_onshore',
      limit: 1,
      orderBy: 'id DESC',
    );
    if (result.isNotEmpty) {
      final locationDropDown =
          jsonDecode(result.first['locationDropDown'] as String)
              as List<dynamic>;
      final exResiterDropDown =
          jsonDecode(result.first['exResiterDropDown'] as String)
              as List<dynamic>;
      return {
        'status': true,
        'message': 'Data successfully!',
        'result': {
          'locationDropDown': locationDropDown,
          'exResiterDropDown': exResiterDropDown,
        },
        'created_by': result.first['created_by'],
        'created_at': result.first['created_at'],
        'updated_by': result.first['updated_by'],
        'updated_at': result.first['updated_at'],
        'lastSync': result.first['lastSync'],
        'syncFlag': result.first['syncFlag'],
      };
    }
    return null;
  }

  Future<void> saveInspectionChecklistOnshore(Map<String, dynamic> data) async {
    final db = await initOnshoreDB();
    await db.insert(
        'inspection_checklist_onshore',
        {
          'checkLists': jsonEncode(data['checkLists']),
          'checkListDetails': jsonEncode(data['checkListDetails']),
          'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at': data['updated_at'] ?? DateTime.now().toIso8601String(),
          'created_by': data['created_by'],
          'updated_by': data['updated_by'],
          'lastSync': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getChecklistDataOnshore() async {
    final db = await onshoreDatabase;
    List<Map<String, dynamic>> result =
        await _safeBatchQuery(db, 'inspection_checklist_onshore');
    if (result.isNotEmpty) {
      final checklist = result[0];
      return {
        'checkLists': jsonDecode(checklist['checkLists']),
        'checkListDetails': jsonDecode(checklist['checkListDetails']),
        'created_at': checklist['created_at'],
        'updated_at': checklist['updated_at'],
        'created_by': checklist['created_by'],
        'updated_by': checklist['updated_by'],
        'lastSync': checklist['lastSync'],
      };
    }
    return null;
  }

  Future<String?> saveFunctionalAreaOnshore(
    Map<String, dynamic> functionalArea,
  ) async {
    final db = await onshoreDatabase;
    int newId = await db.insert(
      'functional_area_onshore',
      functionalArea,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("newId => $newId");
    String functionalAreaJson =
        functionalArea['functional_area_json'] as String;
    Map<String, dynamic> decodedJson = jsonDecode(functionalAreaJson);
    print("decodedJson => ${jsonEncode(decodedJson)}");
    String? locationId;
    if (decodedJson.containsKey('location')) {
      Map<String, dynamic> locationMap = decodedJson['location'];
      locationMap['locationId'] = newId.toString();
      locationId = locationMap['locationId'];
    }

    functionalArea['functional_area_json'] = jsonEncode(decodedJson);
    print(
        "functionalArea['functional_area_json'] => ${jsonEncode(functionalArea['functional_area_json'])}");
    await db.update(
      'functional_area_onshore',
      {'functional_area_json': functionalArea['functional_area_json']},
      where: 'id = ?',
      whereArgs: [newId],
    );

    return locationId;
  }

  Future<void> updateExRegisterJsonLocationIdOnshore(
    int assetId,
    String locationId,
    Map<String, dynamic> functionalAreaMap,
  ) async {
    final db = await onshoreDatabase;

    final result = await _safeBatchQuery(
      db,
      'exregister_table_onshore',
      columns: ['id', 'exregister_json'],
    );

    for (final row in result) {
      final int recordId = row['id'] as int;
      final String? jsonStr = row['exregister_json'] as String?;
      if (jsonStr == null) continue;

      final dynamic parsedJson = jsonDecode(jsonStr);
      bool isUpdated = false;

      if (parsedJson is List) {
        for (var item in parsedJson) {
          if (item is Map) {
            final asset = (item['asset'] is Map) ? item['asset'] : item;
            if (recordId == assetId ||
                asset?['primaryId']?.toString() == assetId.toString() ||
                asset?['_id']?.toString() == assetId.toString()) {
              _updateAssetObject(asset, locationId, functionalAreaMap);
              isUpdated = true;
              break;
            }
          }
        }
      } else if (parsedJson is Map) {
        final asset = (parsedJson['asset'] is Map) ? parsedJson['asset'] : parsedJson;
        if (recordId == assetId ||
            asset?['primaryId']?.toString() == assetId.toString() ||
            asset?['_id']?.toString() == assetId.toString()) {
          _updateAssetObject(asset, locationId, functionalAreaMap);
          isUpdated = true;
        }
      }

      if (isUpdated) {
        await db.update(
          'exregister_table_onshore',
          {'exregister_json': jsonEncode(parsedJson)},
          where: 'id = ?',
          whereArgs: [recordId],
        );
        break;
      }
    }
  }

  Future<void> updateFunctionalAreaAndExRegistersOnshore(
    Map<String, dynamic> updatedFunctionalArea,
  ) async {
    final db = await onshoreDatabase;
    final updatedFunctionalAreaJson =
        updatedFunctionalArea['functional_area_json'] as String;
    final updatedFunctionalAreaData =
        jsonDecode(updatedFunctionalAreaJson) as Map<String, dynamic>;
    final updatedLocationId =
        updatedFunctionalAreaData['location']?['locationId'];
    if (updatedLocationId == null) {
      throw ArgumentError(
        'Invalid functional_area_json: locationId is missing',
      );
    }

    await db.update(
      'functional_area_onshore',
      updatedFunctionalArea,
      where: 'functional_area_json LIKE ? OR id = ?',
      whereArgs: [
        '%"locationId":"$updatedLocationId"%',
        int.tryParse(updatedLocationId) ?? -1,
      ],
    );

    final relatedExRegisters = await _safeBatchQuery(
      db,
      'exregister_table_onshore',
      where: 'exregister_json LIKE ?',
      whereArgs: ['%"locationId":"$updatedLocationId"%'],
    );

    final fieldsToUpdate = [
      'location',
      'areaClassDrawNo',
      'areaClassDrawAttach',
      'areaClassDrawAttachOrgName',
      'eqpmtLytDrawNo',
      'eqpmtLytDrawAttach',
      'eqpmtLytDrawAttachOrgName',
      'subArea',
      'area',
      'locationLatitude',
      'locationLongitude',
      'zone',
      'locationGasGroup',
      'locationTClass',
      'locationIpRating',
      'deckLevel',
      'isActive',
    ];

    for (final exRegister in relatedExRegisters) {
      final exRegisterJsonString = exRegister['exregister_json'] as String;
      final exRegisterData =
          jsonDecode(exRegisterJsonString) as Map<String, dynamic>;

      if (exRegisterData['asset']?['locationId'] == updatedLocationId) {
        final updatedExRegisterData = Map<String, dynamic>.from(exRegisterData);
        final asset = updatedExRegisterData['asset'] as Map<String, dynamic>;

        for (final field in fieldsToUpdate) {
          if (updatedFunctionalAreaData['location'] != null &&
              updatedFunctionalAreaData['location'].containsKey(field)) {
            asset[field] = updatedFunctionalAreaData['location'][field];
          } else if (updatedFunctionalAreaData.containsKey(field)) {
            asset[field] = updatedFunctionalAreaData[field];
          }
        }

        updatedExRegisterData['exregister_json'] = jsonEncode(
          updatedExRegisterData,
        );

        final updatedExRegisterJsonString = jsonEncode(updatedExRegisterData);
        await db.update(
          'exregister_table_onshore',
          {'exregister_json': updatedExRegisterJsonString},
          where: 'id = ?',
          whereArgs: [exRegister['id']],
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaOnshore() async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(db, 'functional_area_onshore');
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaByOffsetOnshore(
    int skip,
    int limit,
  ) async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(
      db,
      'functional_area_onshore',
      orderBy: 'id DESC',
      limit: limit,
      offset: skip,
    );
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaBySortingOnshore(
    String sortField,
    String sortOrder,
  ) async {
    final db = await onshoreDatabase;
    final normalizedSortOrder =
        sortOrder.toLowerCase() == "descending" ? "DESC" : "ASC";
    String query = '''
    SELECT * FROM functional_area_onshore
    ORDER BY json_extract(functional_area_json, '\$.location.$sortField') $normalizedSortOrder
  ''';
    return await _safeBatchRawQuery(db, query);
  }

  Future<List<Map<String, dynamic>>> getFunctionalAreaDataOnshore() async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(db, 'functional_area_onshore');
  }

  Future<Map<String, dynamic>?> getFunctionalAreaByIdOnshore(
    String locationId,
  ) async {
    final db = await onshoreDatabase;
    final results = await _safeBatchQuery(
      db,
      'functional_area_onshore',
      where: 'functional_area_json LIKE ?',
      whereArgs: ['%"locationId":"$locationId"%'],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Future<String> saveExRegisterOnshore(
  //   Map<String, dynamic> exRegisterJson,
  // ) async {
  //   final db = await onshoreDatabase;

  //   // Decode the JSON
  //   String exregisterJsonString = exRegisterJson['exregister_json'] as String;
  //   Map<String, dynamic> decodedJson = jsonDecode(exregisterJsonString);

  //   // Insert to get an auto ID
  //   int newId = await db.insert(
  //     'exregister_table_onshore',
  //     exRegisterJson,
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );

  //   // Update the asset data inside JSON
  //   if (decodedJson.containsKey('asset')) {
  //     Map<String, dynamic> assetMap = decodedJson['asset'];
  //     assetMap['_id'] = newId.toString();
  //     assetMap['primaryId'] = newId;
  //   }

  //   // Save back the JSON
  //   final updatedJsonString = jsonEncode(decodedJson);

  //   // Update both JSON and asset_id column
  //   await db.update(
  //     'exregister_table_onshore',
  //     {'exregister_json': updatedJsonString, 'asset_id': newId.toString()},
  //     where: 'id = ?',
  //     whereArgs: [newId],
  //   );

  //   return newId.toString();
  // }

  Future<List<Map<String, dynamic>>> getExRegisterOnshore() async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(db, 'exregister_table_onshore');
  }

  Future<List<Map<String, dynamic>>> getExRegisterByOffsetOnshore(
    int skip,
    int limit,
  ) async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(
      db,
      'exregister_table_onshore',
      orderBy: 'id DESC',
      limit: limit,
      offset: skip,
    );
  }

  Future<List<Map<String, dynamic>>> getExRegisterBySortingOnshore(
    String sortField,
    String sortOrder,
  ) async {
    final db = await onshoreDatabase;
    final normalizedSortOrder =
        sortOrder.toLowerCase() == "descending" ? "DESC" : "ASC";
    String query;
    if (sortField == 'inspectionStatus' || sortField == 'currentStatus') {
      final sortOrderValues =
          sortOrder.split(',').map((value) => value.trim()).toList();
      final caseStatements = <String>[];
      int caseIndex = 1;
      for (final value in sortOrderValues) {
        caseStatements.add(
          "WHEN json_extract(exregister_json, '\$.asset.$sortField') = '$value' THEN $caseIndex",
        );
        caseIndex++;
      }
      caseStatements.add(
        "WHEN json_extract(exregister_json, '\$.asset.$sortField') IS NULL OR "
        "TRIM(json_extract(exregister_json, '\$.asset.$sortField')) = '' THEN $caseIndex",
      );
      caseIndex++;
      caseStatements.add("ELSE $caseIndex");
      query = '''
      SELECT * FROM exregister_table_onshore
      ORDER BY 
        CASE 
          ${caseStatements.join('\n')}
        END $normalizedSortOrder
    ''';
    } else {
      query = '''
      SELECT * FROM exregister_table_onshore
      ORDER BY 
        CASE 
          WHEN json_extract(exregister_json, '\$.asset.$sortField') IS NULL OR 
               TRIM(json_extract(exregister_json, '\$.asset.$sortField')) = '' THEN ${sortOrder.toLowerCase() == "ascending" ? 0 : 1}
          ELSE ${sortOrder.toLowerCase() == "ascending" ? 1 : 0}
        END ASC, 
        CASE 
          WHEN json_extract(exregister_json, '\$.asset.$sortField') GLOB '[0-9]*' THEN 
            CAST(json_extract(exregister_json, '\$.asset.$sortField') AS INTEGER)
          ELSE 
            LOWER(json_extract(exregister_json, '\$.asset.$sortField'))
        END $normalizedSortOrder
    ''';
    }
    return await _safeBatchRawQuery(db, query);
  }

  Future<Map<String, dynamic>?> getExRegisterByIdOnshore(String assetId) async {
    final db = await onshoreDatabase;
    final results = await _safeBatchQuery(db, 'exregister_table_onshore');
    for (final row in results) {
      if (row['id']?.toString() == assetId) {
        return row;
      }
    }
    for (final row in results) {
      final exRegisterJson = row['exregister_json'];
      if (exRegisterJson == null) continue;
      final jsonMap = (exRegisterJson is String)
          ? jsonDecode(exRegisterJson) as Map<String, dynamic>
          : exRegisterJson as Map<String, dynamic>;
      final asset = (jsonMap['asset'] is Map)
          ? jsonMap['asset'] as Map<String, dynamic>
          : jsonMap;
      if (asset['primaryId']?.toString() == assetId) {
        return row;
      }
    }
    for (final row in results) {
      final exRegisterJson = row['exregister_json'];
      if (exRegisterJson == null) continue;
      final jsonMap = (exRegisterJson is String)
          ? jsonDecode(exRegisterJson) as Map<String, dynamic>
          : exRegisterJson as Map<String, dynamic>;
      final asset = (jsonMap['asset'] is Map)
          ? jsonMap['asset'] as Map<String, dynamic>
          : jsonMap;
      if (asset['_id']?.toString() == assetId || asset['id']?.toString() == assetId) {
        return row;
      }
    }
    return null;
  }

  Future<int> deleteExRegisterByIdOnshore(String assetId, String id) async {
    final db = await onshoreDatabase;
    return await db.delete(
      'exregister_table_onshore',
      where: 'id = ?',
      whereArgs: [id.isNotEmpty ? id : assetId],
    );
  }

  Future<int> deleteExRegisterCollectionByIdOnshore(
    String assetId,
    List<String> assetIds,
  ) async {
    final db = await onshoreDatabase;

    final results = await _safeBatchQuery(db, 'exregister_table_onshore');

    final idsToDelete = results
        .where((row) {
          final exRegisterJson = row['exregister_json'] as String;
          final jsonMap = jsonDecode(exRegisterJson) as Map<String, dynamic>;
          final asset = jsonMap['asset'] ?? jsonMap;
          return assetIds.contains(asset['_id']?.toString()) ||
              assetIds.contains(asset['primaryId']?.toString()) ||
              assetIds.contains(row['id']?.toString());
        })
        .map((row) => row['id'])
        .toList();

    if (idsToDelete.isNotEmpty) {
      final placeholders = List.filled(idsToDelete.length, '?').join(', ');
      return await db.delete(
        'exregister_table_onshore',
        where: 'id IN ($placeholders)',
        whereArgs: idsToDelete,
      );
    }

    return 0;
  }

  Future<String> saveExRegisterOnshore(
    Map<String, dynamic> exRegisterJson,
  ) async {
    final db = await onshoreDatabase;
    int newId = await db.insert(
      'exregister_table_onshore',
      exRegisterJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    String exregisterJsonString = exRegisterJson['exregister_json'] as String;
    Map<String, dynamic> decodedJson = jsonDecode(exregisterJsonString);
    Map<String, dynamic> assetMap = (decodedJson['asset'] is Map)
        ? Map<String, dynamic>.from(decodedJson['asset'] as Map)
        : Map<String, dynamic>.from(decodedJson);
    assetMap['_id'] = newId.toString();
    assetMap['primaryId'] = newId;
    assetMap['id'] = newId.toString();
    final updatedJsonString = jsonEncode({'asset': assetMap});
    await db.update(
      'exregister_table_onshore',
      {'exregister_json': updatedJsonString},
      where: 'id = ?',
      whereArgs: [newId],
    );
    return newId.toString();
  }

  Future<void> updateExRegisterByIdOnshore(
    Map<String, dynamic> exRegister,
  ) async {
    final db = await onshoreDatabase;
    final exRegisterJson = exRegister['exregister_json'] as String;
    final decodedJson = jsonDecode(exRegisterJson) as Map<String, dynamic>;
    final assetMap = (decodedJson['asset'] is Map)
        ? Map<String, dynamic>.from(decodedJson['asset'] as Map)
        : Map<String, dynamic>.from(decodedJson);

    final primaryId = assetMap['primaryId'] ?? decodedJson['primaryId'] ?? exRegister['id'] ?? assetMap['_id'];
    int? targetRowId = (primaryId != null) ? int.tryParse(primaryId.toString()) : null;

    if (targetRowId != null && targetRowId > 0) {
      assetMap['primaryId'] = targetRowId;
      assetMap['_id'] = targetRowId.toString();
      final updatedJsonString = jsonEncode({'asset': assetMap});
      final rowsUpdated = await db.update(
        'exregister_table_onshore',
        {
          'exregister_json': updatedJsonString,
          if (exRegister['updated_by'] != null) 'updated_by': exRegister['updated_by'],
          if (exRegister['updated_date'] != null) 'updated_date': exRegister['updated_date'],
        },
        where: 'id = ?',
        whereArgs: [targetRowId],
      );
      if (rowsUpdated > 0) return;
    }

    final assetId = assetMap['_id'] ?? assetMap['assetId'] ?? assetMap['id'];
    if (assetId != null && assetId.toString().isNotEmpty) {
      final allRows = await _safeBatchQuery(db, 'exregister_table_onshore');
      for (final row in allRows) {
        try {
          final rowJson = (row['exregister_json'] is String)
              ? jsonDecode(row['exregister_json'])
              : row['exregister_json'];
          final rowAsset = (rowJson is Map) ? (rowJson['asset'] ?? rowJson) : {};
          if (row['id']?.toString() == assetId.toString() ||
              rowAsset['primaryId']?.toString() == assetId.toString() ||
              rowAsset['_id']?.toString() == assetId.toString()) {
            final rowId = row['id'];
            assetMap['primaryId'] = rowId;
            assetMap['_id'] = rowId.toString();
            final updatedJsonString = jsonEncode({'asset': assetMap});
            await db.update(
              'exregister_table_onshore',
              {
                'exregister_json': updatedJsonString,
                if (exRegister['updated_by'] != null) 'updated_by': exRegister['updated_by'],
                if (exRegister['updated_date'] != null) 'updated_date': exRegister['updated_date'],
              },
              where: 'id = ?',
              whereArgs: [rowId],
            );
            return;
          }
        } catch (_) {}
      }
    }
  }
  // Future<void> updateExRegisterByIdOnshore(
  //   Map<String, dynamic> exRegister,
  // ) async {
  //   final db = await onshoreDatabase;
  //   final exRegisterJson = exRegister['exregister_json'] as String;
  //   final decodedJson = jsonDecode(exRegisterJson) as Map<String, dynamic>;

  //   final assetId = decodedJson['asset']?['_id'];
  //   if (assetId == null) {
  //     throw ArgumentError('Invalid exregister_json: asset _id is missing');
  //   }

  //   // Check if record exists by asset_id
  //   final existing = await db.query(
  //     'exregister_table_onshore',
  //     where: 'asset_id = ?',
  //     whereArgs: [assetId],
  //   );

  //   if (existing.isNotEmpty) {
  //     final rowsUpdated = await db.update(
  //       'exregister_table_onshore',
  //       {
  //         'exregister_json': exRegisterJson,
  //         'updated_by': exRegister['updated_by'],
  //         'updated_date': exRegister['updated_date'],
  //       },
  //       where: 'asset_id = ?',
  //       whereArgs: [assetId],
  //     );
  //
  //   } else {
  //     throw Exception('❌ Ex Register with asset_id $assetId not found');
  //   }
  // }

  Future<void> updateExRegisterByPrimaryIdOnshore(
    Map<String, dynamic> exRegister,
  ) async {
    final db = await onshoreDatabase;
    final exRegisterJson = exRegister['exregister_json'];
    if (exRegisterJson == null) {
      throw ArgumentError('Invalid input: exregister_json is missing');
    }
    final decodedJson = jsonDecode(exRegisterJson) as Map<String, dynamic>;
    final asset = decodedJson['asset'];
    if (asset == null || asset['primaryId'] == null) {
      throw ArgumentError(
        'Invalid exregister_json: asset or asset primaryId is missing',
      );
    }
    final primaryId = asset['primaryId'];
    final rowsAffected = await db.update(
      'exregister_table_onshore',
      exRegister,
      where: 'id = ?',
      whereArgs: [primaryId],
    );
    if (rowsAffected == 0) {
      throw Exception('Ex Register with primaryId $primaryId not found');
    }
  }

  Future<int> uploadFilesOnshore(Map<String, dynamic> data) async {
    final db = await initOnshoreDB();
    return await db.insert(
      'file_upload_onshore',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> uploadImageOnshore(Map<String, dynamic> data) async {
    final db = await initOnshoreDB();
    return await db.insert(
      'image_upload_onshore',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveWorkOrderAssetOnshore(Map<String, dynamic> workOrder) async {
    final db = await onshoreDatabase;
    // final id = workOrder['id'];
    /// -----------------------------
    /// EXTRACT DATA
    /// -----------------------------
    final Map<String, dynamic> workOrderJson = workOrder['work_order_json'];

    final Map<String, dynamic> assetJson =
        workOrderJson['assets']; // ✅ SINGLE ASSET

    final String workOrderId = workOrderJson['_id'].toString();
    final String assetId = assetJson['_id'].toString();

    /// -----------------------------
    /// CLEAN WORK ORDER (REMOVE ASSET)
    /// -----------------------------
    final Map<String, dynamic> cleanWorkOrderJson =
        Map<String, dynamic>.from(workOrderJson);
    cleanWorkOrderJson.remove('assets');

    /// -----------------------------
    /// BUILD SMALL SAFE JSON
    /// -----------------------------
    final Map<String, dynamic> dbJson = {
      'workOrder': cleanWorkOrderJson,
      'asset': assetJson, // ✅ ONE ASSET ONLY
    };

    /// -----------------------------
    /// INSERT / UPDATE ASSET ROW
    /// -----------------------------
    await db.insert(
      'workOrder_assets_onshore',
      {
        'id': assetId, // ✅ IMPORTANT: ASSET ID, NOT WORK ORDER ID
        'work_order_json': jsonEncode(dbJson),
        'created_by': workOrder['created_by'],
        'updated_by': workOrder['updated_by'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    /// ======================================================================
    /// BELOW CODE (WORK ORDER TABLE, FUNCTIONAL AREA, EX REGISTER)
    /// ✅ KEPT AS-IS
    /// ======================================================================

    /// -----------------------------
    /// WORK ORDER TABLE
    /// -----------------------------
    final workOrderTableData = {
      'work_order_table_onshore_json': jsonEncode({
        'work_order': {
          '_id': workOrderId,
          'woNumber': workOrderJson['woNumber'],
          'woType': workOrderJson['woType'],
          'discipline': workOrderJson['discipline'] ?? '',
          'woDate': workOrderJson['woDate'] ?? '',
          'department': workOrderJson['department'] ?? '',
          'maintanaceType': workOrderJson['maintanaceType'] ?? '',
          'description': workOrderJson['description'] ?? '',
          'startDate': workOrderJson['startDate'] ?? '',
          'endDate': workOrderJson['endDate'] ?? '',
          'duration': workOrderJson['duration'] ?? '',
          'permitType': workOrderJson['permitType'] ?? '',
          'priority': workOrderJson['priority'] ?? '',
          'status': workOrderJson['status'],
          'remark': workOrderJson['remark'],
          'progress': workOrderJson['progress'],
          'currentStatus': workOrderJson['currentStatus'] ?? '',
        },
      }),
      'created_by': workOrder['created_by'],
      'updated_by': workOrder['updated_by'],
    };

    final existingWordOrderData = await db.query(
      'work_order_table_onshore',
      columns: ['id'],
      where: 'work_order_table_onshore_json LIKE ?',
      whereArgs: ['%"_id":"$workOrderId"%'],
    );

    if (existingWordOrderData.isNotEmpty) {
      await db.update(
        'work_order_table_onshore',
        workOrderTableData,
        where: 'id = ?',
        whereArgs: [existingWordOrderData.first['id']],
      );
    } else {
      await db.insert(
        'work_order_table_onshore',
        workOrderTableData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    /// -----------------------------
    /// FUNCTIONAL AREA (UNCHANGED)
    /// -----------------------------
    final assetFuncationJson = assetJson;
    final locationId = assetFuncationJson['locationId'];

    // dynamic gps = workOrderJson['gpsCoordinates'] == "" ||
    //         workOrderJson['gpsCoordinates'] == null
    //     ? null
    //     : workOrderJson['gpsCoordinates'].toString().split(',');

    final functionalAreaData = {
      'functional_area_json': jsonEncode({
        'location': {
          'locationId': assetFuncationJson['locationId'],
          'location': assetFuncationJson['location'],
          'area': assetFuncationJson['area'] ?? '',
          'deckLevel': assetFuncationJson['deckLevel'] ?? '',
          'subArea': assetFuncationJson['subArea'] ?? '',
          'zone': assetFuncationJson['zone'] ?? '',
          'locationGasGroup': assetFuncationJson['locationGasGroup'] ?? [],
          'locationTClass': assetFuncationJson['locationTClass'] ?? [],
          'locationIpRating': assetFuncationJson['locationIpRating'] ?? [],
          'tAmbient': assetFuncationJson['locationTAmbient'] ?? '',
          'areaClassDrawAttach':
              assetFuncationJson['areaClassDrawAttach'] ?? [],
          'areaClassDrawNo': assetFuncationJson['areaClassDrawNo'] ?? [],
          'areaClassDrawAttachOrgName':
              assetFuncationJson['areaClassDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawNo': assetFuncationJson['eqpmtLytDrawNo'] ?? [],
          'eqpmtLytDrawAttach': assetFuncationJson['eqpmtLytDrawAttach'] ?? [],
          'eqpmtLytDrawAttachOrgName':
              assetFuncationJson['eqpmtLytDrawAttachOrgName'] ?? [],
          'locationLongitude': assetFuncationJson['locationLongitude'],
          //  ??
          //     (gps != null && gps.length > 1 ? gps[1].trim() : ''),
          'locationLatitude': assetFuncationJson['locationLatitude'],
          //  ??
          //     (gps != null && gps.length > 0 ? gps[0].trim() : ''),
          'isActive': assetFuncationJson['isActive'] ?? '',
          'areaStatus': assetFuncationJson['areaStatus'],
          'isDuplicate': false,
        },
      }),
      'created_by': workOrder['created_by'],
      'updated_by': workOrder['updated_by'],
    };
    // final locationId = assetFuncationJson['locationId'];
    final existingFunctionalArea = await db.query(
      'functional_area_onshore',
      columns: ['id'],
      where: 'functional_area_json LIKE ?',
      whereArgs: ['%"locationId":"$locationId"%'],
    );

    if (existingFunctionalArea.isNotEmpty) {
      await db.update(
        'functional_area_onshore',
        functionalAreaData,
        where: 'id = ?',
        whereArgs: [existingFunctionalArea.first['id']],
      );
    } else {
      await db.insert(
        'functional_area_onshore',
        functionalAreaData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    final exRegisterData = {
      'exregister_json': jsonEncode({
        'asset': {
          '_id': assetFuncationJson['_id'] ?? '',
          'locationId': assetFuncationJson['locationId'],
          'location': assetFuncationJson['location'],
          'area': assetFuncationJson['area'] ?? '',
          'zone': assetFuncationJson['zone'] ?? '',
          'locationGasGroup': assetFuncationJson['locationGasGroup'] ?? [],
          'locationTClass': assetFuncationJson['locationTClass'] ?? [],
          'locationIpRating': assetFuncationJson['locationIpRating'] ?? [],
          'areaClassDrawAttach':
              assetFuncationJson['areaClassDrawAttach'] ?? [],
          'areaClassDrawNo': assetFuncationJson['areaClassDrawNo'] ?? [],
          'areaClassDrawAttachOrgName':
              assetFuncationJson['areaClassDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawAttachOrgName':
              assetFuncationJson['eqpmtLytDrawAttachOrgName'] ?? [],
          'eqpmtLytDrawAttach': assetFuncationJson['eqpmtLytDrawAttach'] ?? [],
          'eqpmtLytDrawNo': assetFuncationJson['eqpmtLytDrawNo'] ?? [],
          'deckLevel': assetFuncationJson['deckLevel'] ?? '',
          'locationLongitude': assetFuncationJson['locationLongitude'] ?? '',
          'locationLatitude': assetFuncationJson['locationLatitude'] ?? '',
          'isActive': assetFuncationJson['isActive'] ?? '',
          'areaStatus': assetFuncationJson['areaStatus'],
          'eqpmtCatg': assetFuncationJson['eqpmtCatg'] ?? '',
          'description': assetFuncationJson['description'] ?? '',
          'atexCatg': assetFuncationJson['atexCatg'] ?? [],
          'epl': assetFuncationJson['epl'] ?? [],
          'protectionType': assetFuncationJson['protectionType'] ?? [],
          'subArea': assetFuncationJson['subArea'] ?? '',
          'rfidRef': assetFuncationJson['rfidRef'] ?? '',
          'gpsCord': assetFuncationJson['gpsCord'] ?? '',
          'eqpmtTag': assetFuncationJson['eqpmtTag'] ?? '',
          'circuitId': assetFuncationJson['circuitId'] ?? '',
          'cableId': assetFuncationJson['cableId'] ?? '',
          'equipmentCategory': assetFuncationJson['equipmentCategory'] ?? '',
          'manufacturer': assetFuncationJson['manufacturer'] ?? '',
          'type': assetFuncationJson['type'] ?? '',
          'serialNumber': assetFuncationJson['serialNumber'] ?? '',
          'protectionStd': assetFuncationJson['protectionStd'] ?? '',
          'equipmentGasGroup': assetFuncationJson['equipmentGasGroup'] ?? [],
          'equipmentTClass': assetFuncationJson['equipmentTClass'] ?? [],
          'equipmentIpRating': assetFuncationJson['equipmentIpRating'] ?? [],
          'certfnBody': assetFuncationJson['certfnBody'] ?? '',
          'locationTAmbient': assetFuncationJson['locationTAmbient'] ?? '',
          'certfnNo': assetFuncationJson['certfnNo'] ?? '',
          'tAmbient': assetFuncationJson['tAmbient'] ?? '',
          'tAmbientEquip': assetFuncationJson['tAmbientEquip'] ?? '',
          'inspectionSignOff': assetFuncationJson['inspectionSignOff'] ?? '',
          'repairSignOff': assetFuncationJson['repairSignOff'] ?? '',
          'specialCond': assetFuncationJson['specialCond'] ?? '',
          'oracleId': assetFuncationJson['oracleId'] ?? '',
          'yesNoSelection': assetFuncationJson['yesNoSelection'] ?? {},
          'checkList': assetFuncationJson['checkList'] ?? [],
          'inspectedBy': assetFuncationJson['inspectedBy'] ?? '',
          'inspectedDate': assetFuncationJson['inspectedDate'] ?? '',
          'repairedBy': assetFuncationJson['repairedBy'] ?? '',
          'repairedDate': assetFuncationJson['repairedDate'] ?? '',
          'faultyItems': assetFuncationJson['faultyItems'] ?? '',
          'repairPriority': assetFuncationJson['repairPriority'] ?? '',
          'inspectionStatus': assetFuncationJson['inspectionStatus'] ?? '',
          'defectOverallCondition':
              assetFuncationJson['defectOverallCondition'] ?? '',
          'defectIsolation': assetFuncationJson['defectIsolation'] ?? '',
          'defectOtherRequirements':
              assetFuncationJson['defectOtherRequirements'] ?? [],
          'remarks': assetFuncationJson['remarks'] ?? '',
          'dataSheet': assetFuncationJson['dataSheet'] ?? '',
          'dataSheetNo': assetFuncationJson['dataSheetNo'] ?? '',
          'dataSheetOrgName': assetFuncationJson['dataSheetOrgName'] ?? '',
          'defectivePhoto1': assetFuncationJson['defectivePhoto1'] ?? '',
          'defectivePhoto1OrgName':
              assetFuncationJson['defectivePhoto1OrgName'] ?? '',
          'defectivePhoto2': assetFuncationJson['defectivePhoto2'] ?? '',
          'defectivePhoto2OrgName':
              assetFuncationJson['defectivePhoto2OrgName'] ?? '',
          'defectivePhoto3': assetFuncationJson['defectivePhoto3'] ?? '',
          'defectivePhoto3OrgName':
              assetFuncationJson['defectivePhoto3OrgName'] ?? '',
          'defectivePhoto4': assetFuncationJson['defectivePhoto4'] ?? '',
          'defectivePhoto4OrgName':
              assetFuncationJson['defectivePhoto4OrgName'] ?? '',
          'defectivePhoto5': assetFuncationJson['defectivePhoto5'] ?? '',
          'defectivePhoto5OrgName':
              assetFuncationJson['defectivePhoto5OrgName'] ?? '',
          'defectivePhoto6': assetFuncationJson['defectivePhoto6'] ?? '',
          'defectivePhoto6OrgName':
              assetFuncationJson['defectivePhoto6OrgName'] ?? '',
          'materials': assetFuncationJson['materials'] ?? [],
          'existingFaults': assetFuncationJson['existingFaults'] ?? '',
          'correctiveDefectCategory':
              assetFuncationJson['correctiveDefectCategory'] ?? '',
          'currentStatus': assetFuncationJson['currentStatus'] ?? '',
          'correctiveOverallCondition':
              assetFuncationJson['correctiveOverallCondition'] ?? '',
          'correctiveisolation':
              assetFuncationJson['correctiveisolation'] ?? '',
          'correctiveOtherRequirements':
              assetFuncationJson['correctiveOtherRequirements'] ?? '',
          'repairsDone': assetFuncationJson['repairsDone'] ?? '',
          'rbiStrategy':
              (assetFuncationJson['rbiStrategy'] as Map<String, dynamic>?) ??
                  {},
          'additionalInfoForRepairs':
              assetFuncationJson['additionalInfoForRepairs'] ?? '',
          'remarksIfAny': assetFuncationJson['remarksIfAny'] ?? '',
          'supplementaryMaterialReq':
              assetFuncationJson['supplementaryMaterialReq'] ?? [],
          'defectCertificationOrgName':
              assetFuncationJson['defectCertificationOrgName'] ?? '',
          'defectCertificationNo':
              assetFuncationJson['defectCertificationNo'] ?? '',
          'defectCertificationAttach':
              assetFuncationJson['defectCertificationAttach'] ?? '',
          'correctiveCertificationNo':
              assetFuncationJson['correctiveCertificationNo'] ?? '',
          'correctiveCertificationOrgName':
              assetFuncationJson['correctiveCertificationOrgName'] ?? '',
          'correctiveCertificationAttach':
              assetFuncationJson['correctiveCertificationAttach'] ?? '',
          'inspectionChecklistType':
              assetFuncationJson['inspectionChecklistType'] ?? [],
          'inspectionType': assetFuncationJson['inspectionType'] ?? '',
          'inspectionGrade': assetFuncationJson['inspectionGrade'] ?? '',
          'equipmentEquipmentType':
              assetFuncationJson['equipmentEquipmentType'] ?? '',
          'correctivePhoto1': assetFuncationJson['correctivePhoto1'] ?? '',
          'correctivePhoto1OrgName':
              assetFuncationJson['correctivePhoto1OrgName'] ?? '',
          'correctivePhoto2': assetFuncationJson['correctivePhoto2'] ?? '',
          'correctivePhoto2OrgName':
              assetFuncationJson['correctivePhoto2OrgName'] ?? '',
          'correctivePhoto3': assetFuncationJson['correctivePhoto3'] ?? '',
          'correctivePhoto3OrgName':
              assetFuncationJson['correctivePhoto3OrgName'] ?? '',
          'correctivePhoto4': assetFuncationJson['correctivePhoto4'] ?? '',
          'correctivePhoto4OrgName':
              assetFuncationJson['correctivePhoto4OrgName'] ?? '',
          'correctivePhoto5': assetFuncationJson['correctivePhoto5'] ?? '',
          'correctivePhoto5OrgName':
              assetFuncationJson['correctivePhoto5OrgName'] ?? '',
          'correctivePhoto6': assetFuncationJson['correctivePhoto6'] ?? '',
          'correctivePhoto6OrgName':
              assetFuncationJson['correctivePhoto6OrgName'] ?? '',
          'primaryId': assetFuncationJson['_id'] ?? '',
          'defectDefectCategory':
              assetFuncationJson['defectDefectCategory'] ?? '',
          'repairDuration': assetFuncationJson['repairDuration'] ?? '',
          'repairTimeEstimate': assetFuncationJson['repairTimeEstimate'] ?? '',
          'isDuplicate': false,
        },
      }),
      'created_by': workOrder['created_by'],
      'updated_by': workOrder['updated_by'],
    };
    final assetIdData = assetFuncationJson['_id'];
    final existingExRegister = await db.query(
      'exregister_table_onshore',
      columns: ['id'],
      where: 'exregister_json LIKE ? AND exregister_json LIKE ?',
      whereArgs: ['%"locationId":"$locationId"%', '%"_id":"$assetIdData"%'],
    );
    // final existingExRegister = await db.query(
    //   'exregister_table_onshore',
    //   columns: ['id'],
    //   where: 'exregister_json LIKE ?',
    //   whereArgs: ['%"locationId":"$locationId"%'],
    // );

    int recordId;
    if (existingExRegister.isNotEmpty) {
      recordId = existingExRegister.first['id'] as int;
      final updatedJson = jsonDecode(exRegisterData['exregister_json']!);
      updatedJson['asset']['primaryId'] = recordId;
      exRegisterData['exregister_json'] = jsonEncode(updatedJson);
      await db.update(
        'exregister_table_onshore',
        exRegisterData,
        where: 'id = ?',
        whereArgs: [recordId],
      );
    } else {
      recordId = await db.insert(
        'exregister_table_onshore',
        exRegisterData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final updatedJson = jsonDecode(exRegisterData['exregister_json']!);
      updatedJson['asset']['primaryId'] = recordId;
      exRegisterData['exregister_json'] = jsonEncode(updatedJson);
      await db.update(
        'exregister_table_onshore',
        exRegisterData,
        where: 'id = ?',
        whereArgs: [recordId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getWorkOrderAssetsOnshore() async {
    final db = await onshoreDatabase;
    return await _safeBatchQuery(db, 'workOrder_assets_onshore');
  }

  Future<int> saveMobileSyncServerOnshore(Map<String, dynamic> data) async {
    final db = await initWorkOrderDB();
    return await db.insert(
      'mobile_sync_device',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getMobileSyncServerOnshore(
    String assetId,
    String functionality,
  ) async {
    final db = await initWorkOrderDB();
    final result = await _safeBatchQuery(
      db,
      'mobile_sync_device',
      where: 'assetId = ? AND functionality = ?',
      whereArgs: [assetId, functionality],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMobileSyncServerOnshore(
    Map<String, dynamic> data,
    String assetId,
    String functionality,
  ) async {
    final db = await initWorkOrderDB();
    return await db.update(
      'mobile_sync_device',
      data,
      where: 'assetId = ? AND functionality = ?',
      whereArgs: [assetId, functionality],
    );
  }

  Future<void> updateExRegisterJsonLocationId(
    int assetId,
    String locationId,
    Map<String, dynamic> functionalAreaMap,
  ) async {
    final db = await initWorkOrderDB();
    final result = await _safeBatchQuery(
      db,
      'exregister_table',
      columns: ['id', 'exregister_json'],
    );

    for (final row in result) {
      final int recordId = row['id'] as int;
      final String? jsonStr = row['exregister_json'] as String?;
      if (jsonStr == null) continue;

      final dynamic parsedJson = jsonDecode(jsonStr);
      bool isUpdated = false;

      if (parsedJson is List) {
        for (var item in parsedJson) {
          if (item is Map) {
            final asset = (item['asset'] is Map) ? item['asset'] : item;
            if (recordId == assetId ||
                asset?['primaryId']?.toString() == assetId.toString() ||
                asset?['_id']?.toString() == assetId.toString()) {
              _updateAssetObject(asset, locationId, functionalAreaMap);
              isUpdated = true;
              break;
            }
          }
        }
      } else if (parsedJson is Map) {
        final asset = (parsedJson['asset'] is Map) ? parsedJson['asset'] : parsedJson;
        if (recordId == assetId ||
            asset?['primaryId']?.toString() == assetId.toString() ||
            asset?['_id']?.toString() == assetId.toString()) {
          _updateAssetObject(asset, locationId, functionalAreaMap);
          isUpdated = true;
        }
      }

      if (isUpdated) {
        await db.update(
          'exregister_table',
          {'exregister_json': jsonEncode(parsedJson)},
          where: 'id = ?',
          whereArgs: [recordId],
        );
        break;
      }
    }
  }

  void _updateAssetObject(
    Map<String, dynamic> asset,
    String locationId,
    Map<String, dynamic> functionalAreaMap,
  ) {
    asset['locationId'] = locationId;
    asset['location'] = functionalAreaMap['location'];
    asset['area'] = functionalAreaMap['area'];
    asset['deckLevel'] = functionalAreaMap['deckLevel'];
    asset['subArea'] = functionalAreaMap['subArea'];
    asset['zone'] = functionalAreaMap['zone'];
    asset['locationGasGroup'] = functionalAreaMap['locationGasGroup'];
    asset['locationTClass'] = functionalAreaMap['locationTClass'];
    asset['locationIpRating'] = functionalAreaMap['locationIpRating'];
    asset['locationLatitude'] = functionalAreaMap['locationLatitude'];
    asset['locationLongitude'] = functionalAreaMap['locationLongitude'];
    asset['areaClassDrawNo'] = functionalAreaMap['areaClassDrawNo'];
    asset['areaClassDrawAttach'] = functionalAreaMap['areaClassDrawAttach'];
    asset['areaClassDrawAttachOrgName'] =
        functionalAreaMap['areaClassDrawAttachOrgName'];
    asset['eqpmtLytDrawNo'] = functionalAreaMap['eqpmtLytDrawNo'];
    asset['eqpmtLytDrawAttach'] = functionalAreaMap['eqpmtLytDrawAttach'];
    asset['eqpmtLytDrawAttachOrgName'] =
        functionalAreaMap['eqpmtLytDrawAttachOrgName'];
    asset['isDuplicate'] = false;
  }

  void printFull(String text) {
    const chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {}
  }

  Future<int> deleteFunctionalAreaIdOnshore(List<String> assetIds) async {
    final db = await onshoreDatabase;
    int totalDeleted = 0;

    if (assetIds.isNotEmpty) {
      final results = await _safeBatchQuery(db, 'exregister_table_onshore');

      for (final assetId in assetIds) {
        final matchingRecords = results.where((row) {
          final exRegisterJson = row['exregister_json'] as String?;
          if (exRegisterJson == null) return false;

          final jsonMap = jsonDecode(exRegisterJson) as Map<String, dynamic>;
          return jsonMap['asset']['locationId'] == assetId;
        }).toList();

        for (final record in matchingRecords) {
          final deleted = await db.delete(
            'exregister_table_onshore',
            where: "id = ?",
            whereArgs: [record['id']],
          );
          totalDeleted += deleted;
        }
      }

      final funresults = await _safeBatchQuery(db, 'functional_area_onshore');

      for (final row in funresults) {
        final jsonStr = row['functional_area_json'] as String?;
        if (jsonStr == null) continue;
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        final locationId = jsonMap['location']['locationId'] as String?;
        if (locationId != null && assetIds.contains(locationId)) {
          final deleted = await db.delete(
            'functional_area_onshore',
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          totalDeleted += deleted;
        }
      }
    }

    return totalDeleted;
  }

  Future<int> deleteFunctionalAreaId(List<String> assetIds) async {
    final db = await onshoreDatabase;
    int totalDeleted = 0;

    if (assetIds.isNotEmpty) {
      final results = await _safeBatchQuery(db, 'exregister_table');

      for (final assetId in assetIds) {
        final matchingRecords = results.where((row) {
          final exRegisterJson = row['exregister_json'] as String?;
          if (exRegisterJson == null) return false;

          final jsonMap = jsonDecode(exRegisterJson) as Map<String, dynamic>;
          return jsonMap['asset']['locationId'] == assetId;
        }).toList();

        for (final record in matchingRecords) {
          final deleted = await db.delete(
            'exregister_table',
            where: "id = ?",
            whereArgs: [record['id']],
          );
          totalDeleted += deleted;
        }
      }

      final funresults = await _safeBatchQuery(db, 'functional_area');

      for (final row in funresults) {
        final jsonStr = row['functional_area_json'] as String?;
        if (jsonStr == null) continue;
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        final locationId = jsonMap['location']['locationId'] as String?;
        if (locationId != null && assetIds.contains(locationId)) {
          final deleted = await db.delete(
            'functional_area',
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          totalDeleted += deleted;
        }
      }
    }

    return totalDeleted;
  }

  Future<void> deleteExRegister(String assetId) async {
    final db = await workOrderDatabase;

    final record = await getExRegisterById(assetId);
    if (record != null) {
      final id = record['id'] as int;
      await db.delete(
        'exregister_table',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Delete a single work order row by id
  Future<void> deleteWorkOrderTable(int id) async {
    final db = await workOrderDatabase;
    await db.delete(
      'work_order_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a single functional area row by id
  Future<void> deleteFunctionalArea(dynamic id) async {
    final db = await workOrderDatabase;
    await db.delete(
      'functional_area',
      where: 'functional_area_json LIKE ?',
      whereArgs: ['%"locationId":"$id"%'],
    );
  }

  // Onshore DB versions
  Future<void> deleteExRegisterOnshore(String assetId) async {
    final db = await onshoreDatabase;

    final record = await getExRegisterByIdOnshore(assetId);
    if (record != null) {
      final id = record['id'] as int;
      await db.delete(
        'exregister_table_onshore',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteWorkOrderTableOnshore(int id) async {
    final db = await onshoreDatabase;
    await db.delete(
      'work_order_table_onshore',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFunctionalAreaOnshore(dynamic id) async {
    final db = await onshoreDatabase;
    await db.delete(
      'functional_area_onshore',
      where: 'functional_area_json LIKE ?',
      whereArgs: ['%"locationId":"$id"%'],
    );
  }

  Future<void> vacuumDatabase(bool isOnshore) async {
    final db = isOnshore ? await onshoreDatabase : await workOrderDatabase;
    await db.execute('VACUUM');
  }

  /// 🛠 HELPER: Batched Query to avoid "Row too big for CursorWindow" (Android 2MB limit)
  ///
  /// Strategy: Two-pass approach
  ///   Pass 1 — Fetch ONLY the 'id' column (tiny payload, never overflows CursorWindow)
  ///   Pass 2 — Fetch each full row ONE-BY-ONE using 'WHERE id = ?' with try/catch
  ///            so that oversized rows are gracefully skipped instead of crashing.
  Future<List<Map<String, dynamic>>> _safeBatchQuery(
    Database db,
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    // ── Pass 1: Fetch only IDs (safe — 'id' column is tiny) ──
    List<Map<String, dynamic>> idRows;
    try {
      idRows = await db.query(
        table,
        distinct: distinct,
        columns: ['id'],
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      debugPrint('⚠️ _safeBatchQuery: Failed to fetch IDs from $table: $e');
      return [];
    }

    if (idRows.isEmpty) return [];

    // ── Pass 2: Fetch each full row by ID (skip oversized rows) ──
    List<Map<String, dynamic>> allResults = [];
    for (final idRow in idRows) {
      final rowId = idRow['id'];
      try {
        final rows = await db.query(
          table,
          distinct: distinct,
          columns: columns,
          where: 'id = ?',
          whereArgs: [rowId],
        );
        if (rows.isNotEmpty) {
          allResults.add(rows.first);
        }
      } catch (e) {
        // This row is too large for CursorWindow — skip it and continue
        debugPrint(
            '⚠️ _safeBatchQuery: Skipping oversized row id=$rowId in $table: $e');
        continue;
      }
    }
    return allResults;
  }

  /// 🛠 HELPER: Safe raw query — same two-pass strategy for raw SQL queries.
  Future<List<Map<String, dynamic>>> _safeBatchRawQuery(
    Database db,
    String rawQuery, [
    List<Object?>? arguments,
  ]) async {
    // ── Pass 1: Rewrite the query to fetch ONLY 'id' (safe payload) ──
    List<Map<String, dynamic>> idRows;
    try {
      // Replace 'SELECT *' or 'SELECT <columns>' with 'SELECT id'
      final idQuery = rawQuery.replaceFirstMapped(
        RegExp(r'SELECT\s+.+?\s+FROM', caseSensitive: false),
        (m) => 'SELECT id FROM',
      );
      idRows = await db.rawQuery(idQuery, arguments);
    } catch (e) {
      debugPrint('⚠️ _safeBatchRawQuery: Failed to fetch IDs: $e');
      return [];
    }

    if (idRows.isEmpty) return [];

    // ── Extract the table name so we can query each row by id ──
    final tableMatch =
        RegExp(r'FROM\s+(\w+)', caseSensitive: false).firstMatch(rawQuery);
    if (tableMatch == null) {
      debugPrint('⚠️ _safeBatchRawQuery: Could not extract table name');
      return [];
    }
    final tableName = tableMatch.group(1)!;

    // ── Pass 2: Fetch each full row by ID (skip oversized rows) ──
    List<Map<String, dynamic>> allResults = [];
    for (final idRow in idRows) {
      final rowId = idRow['id'];
      try {
        final rows = await db.query(
          tableName,
          where: 'id = ?',
          whereArgs: [rowId],
        );
        if (rows.isNotEmpty) {
          allResults.add(rows.first);
        }
      } catch (e) {
        debugPrint(
            '⚠️ _safeBatchRawQuery: Skipping oversized row id=$rowId in $tableName: $e');
        continue;
      }
    }
    return allResults;
  }
}
