import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/widgets/server_to_device_table.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDeviceSyncServices extends DeviceSyncServices {
  Map<String, dynamic> responseToReturn = {};

  @override
  Future<Map<String, dynamic>> fetchWorkOrderAssets({
    int limit = 30,
    int offset = 0,
    String? sortField,
    String? sortOrder,
    String? userId,
  }) async {
    return responseToReturn;
  }
}

class FakeAuthUtils implements AuthUtils {
  String? userIdToReturn;
  String? usernameToReturn;
  String? userTypeToReturn;

  @override
  Future<String?> getUserId() async => userIdToReturn;

  @override
  Future<String?> getUsername() async => usernameToReturn;

  @override
  Future<String?> getUserType() async => userTypeToReturn;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Server to Device User ID Filtering Tests', () {
    test('ExRegister model correctly parses and preserves user assignment fields', () {
      final json = {
        '_id': 'asset_1',
        'rfidRef': 'RFID-001',
        'assignedTo': 'user_1',
        'assignedUserId': 'user_1',
        'userId': 'user_1',
        'inspectedId': 'user_1',
        'inspectorId': 'user_1',
        'assignedTeam': ['user_1', 'user_2'],
      };

      final asset = ExRegister.fromJson(json);
      expect(asset.id, 'asset_1');
      expect(asset.assignedTo, 'user_1');
      expect(asset.assignedUserId, 'user_1');
      expect(asset.userId, 'user_1');
      expect(asset.inspectedId, 'user_1');
      expect(asset.inspectorId, 'user_1');
      expect(asset.assignedTeam, ['user_1', 'user_2']);

      final serialized = asset.toJson();
      expect(serialized['assignedTo'], 'user_1');
      expect(serialized['assignedUserId'], 'user_1');
      expect(serialized['userId'], 'user_1');
      expect(serialized['inspectedId'], 'user_1');
      expect(serialized['assignedTeam'], ['user_1', 'user_2']);
    });

    test('WorkOrderTableJson model correctly parses and preserves assignment fields', () {
      final json = {
        '_id': 'wo_1',
        'woNumber': 'WO-101',
        'assigendTeam': ['1'],
        'assignedTo': '1',
        'userId': '1',
        'assignedUserId': '1',
        'inspectorId': '1',
        'assets': [
          {'_id': 'asset_1', 'rfidRef': 'RFID-1'},
          {'_id': 'asset_2', 'rfidRef': 'RFID-2'},
        ],
      };

      final wo = WorkOrderTableJson.fromJson(json);
      expect(wo.id, 'wo_1');
      expect(wo.woNumber, 'WO-101');
      expect(wo.assigendTeam, ['1']);
      expect(wo.assignedTo, '1');
      expect(wo.userId, '1');
      expect(wo.assignedUserId, '1');
      expect(wo.inspectorId, '1');
      expect(wo.assets.length, 2);
    });

    test('User with ID 1 only sees their 10 assigned assets out of 60 total server assets', () async {
      final fakeService = FakeDeviceSyncServices();
      final fakeAuth = FakeAuthUtils()
        ..userIdToReturn = '1'
        ..usernameToReturn = 'user1'
        ..userTypeToReturn = 'Offshore';

      // Create 60 assets: 10 assigned to user 1 (WO 1), 50 assigned to user 2 (WO 2)
      final List<ExRegister> user1Assets = List.generate(10, (i) {
        return ExRegister.fromJson({
          '_id': 'user1_asset_${i + 1}',
          'rfidRef': 'RFID-U1-${i + 1}',
          'location': 'Field A',
          'area': 'Platform 1',
          'deckLevel': 'Deck 1',
          'assignedTo': '1',
          'assignedUserId': '1',
          'isActive': true,
        });
      });

      final List<ExRegister> user2Assets = List.generate(50, (i) {
        return ExRegister.fromJson({
          '_id': 'user2_asset_${i + 1}',
          'rfidRef': 'RFID-U2-${i + 1}',
          'location': 'Field B',
          'area': 'Platform 2',
          'deckLevel': 'Deck 2',
          'assignedTo': '2',
          'assignedUserId': '2',
          'isActive': true,
        });
      });

      final allAssets = [...user1Assets, ...user2Assets];
      expect(allAssets.length, 60);

      final workOrder1 = WorkOrderTableJson.fromJson({
        '_id': 'wo_user_1',
        'woNumber': 'WO-001',
        'assigendTeam': ['1'],
        'assignedTo': '1',
        'assets': user1Assets.map((a) => a.toJson()).toList(),
      });

      final workOrder2 = WorkOrderTableJson.fromJson({
        '_id': 'wo_user_2',
        'woNumber': 'WO-002',
        'assigendTeam': ['2'],
        'assignedTo': '2',
        'assets': user2Assets.map((a) => a.toJson()).toList(),
      });

      final allWorkOrders = [workOrder1, workOrder2];

      fakeService.responseToReturn = {
        'assets': allAssets,
        'work_order': allWorkOrders,
      };

      final bloc = DeviceSyncBloc(
        deviceSyncServices: fakeService,
        authUtils: fakeAuth,
      );

      final states = <DeviceSyncState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadWorkOrder());

      await Future.delayed(const Duration(milliseconds: 300));

      expect(states.any((s) => s is WorkOrderLoaded), isTrue);
      final loadedState = states.firstWhere((s) => s is WorkOrderLoaded) as WorkOrderLoaded;

      // Exactly 10 assets for User 1 must be present!
      expect(loadedState.assets.length, 10);
      expect(loadedState.totalRecords, 10);
      expect(loadedState.assets.every((a) => a.id.startsWith('user1_asset_')), isTrue);
      expect(loadedState.workOrderCollection.length, 1);
      expect(loadedState.workOrderCollection.first.id, 'wo_user_1');
      expect(loadedState.workOrderCollection.first.assets.length, 10);

      await bloc.close();
    });

    test('Individual asset assignment inside a shared work order filters accurately for User 1', () async {
      final fakeService = FakeDeviceSyncServices();
      final fakeAuth = FakeAuthUtils()
        ..userIdToReturn = '1'
        ..usernameToReturn = 'user1'
        ..userTypeToReturn = 'Onshore';

      // Shared work order containing 60 assets: 10 assigned to user 1, 50 to user 2
      final List<ExRegister> mixedAssets = [];
      for (int i = 1; i <= 60; i++) {
        final isUser1 = i <= 10;
        mixedAssets.add(ExRegister.fromJson({
          '_id': 'asset_$i',
          'rfidRef': 'RFID-$i',
          'location': 'Plant X',
          'area': 'Unit Y',
          'assignedTo': isUser1 ? '1' : '2',
          'assignedUserId': isUser1 ? '1' : '2',
        }));
      }

      final sharedWorkOrder = WorkOrderTableJson.fromJson({
        '_id': 'wo_shared_100',
        'woNumber': 'WO-SHARED-100',
        'assigendTeam': ['other_team'], // WO itself is not assigned directly to user 1
        'assets': mixedAssets.map((a) => a.toJson()).toList(),
      });

      fakeService.responseToReturn = {
        'assets': mixedAssets,
        'work_order': [sharedWorkOrder],
      };

      final bloc = DeviceSyncBloc(
        deviceSyncServices: fakeService,
        authUtils: fakeAuth,
      );

      final states = <DeviceSyncState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadNewWorkOrder());

      await Future.delayed(const Duration(milliseconds: 300));

      expect(states.any((s) => s is WorkOrderNewLoaded), isTrue);
      final loadedState = states.firstWhere((s) => s is WorkOrderNewLoaded) as WorkOrderNewLoaded;

      // Only the 10 assets assigned to user 1 must be returned
      expect(loadedState.assets.length, 10);
      expect(loadedState.totalRecords, 10);
      expect(loadedState.workOrderCollection.length, 1);
      expect(loadedState.workOrderCollection.first.assets.length, 10);
      for (var a in loadedState.assets) {
        expect(a.assignedTo, '1');
      }

      await bloc.close();
    });

    testWidgets('ServerToDeviceTable renders user assets properly with correct columns', (WidgetTester tester) async {
      final assets = List.generate(10, (i) {
        return ExRegister.fromJson({
          '_id': 'u1_asset_$i',
          'rfidRef': 'RFID-U1-$i',
          'location': 'Location A',
          'subArea': 'Sub Loc A',
          'area': 'Area A',
          'deckLevel': 'Deck A',
          'zone': 'Zone 1',
          'eqpmtCatg': 'Electrical',
          'eqpmtTag': 'TAG-$i',
          'description': 'Motor $i',
          'manufacturer': 'ABB',
          'protectionType': ['Ex d'],
          'equipmentGasGroup': ['IIB'],
          'equipmentTClass': ['T4'],
          'faultyItems': 0,
          'inspectionStatus': 'Green',
          'repairsDone': 0,
          'existingFaults': 0,
          'currentStatus': 'Green',
          'assignedTo': '1',
        });
      });

      final headers = [
        "RFID Reference",
        "Location",
        "Sub Location",
        "Area",
        "Zone",
        "Discipline",
        "Equipment Tag Number",
        "Equipment Description",
        "Equipment Manufacturer",
        "Equipment Protection",
        "Inspection Faults",
        "Inspection Status",
        "Completed Repairs",
        "Existing Faults",
        "Current Status",
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServerToDeviceTable(
              assets: assets,
              headers: headers,
              onRowSelected: (i) {},
              sortOrder: 'descending',
              selectedFilters: const [],
              collectionSelectedFilter: const {},
              registerCollections: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ServerToDeviceTable), findsOneWidget);
      expect(find.text('RFID Reference'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Sub Location'), findsOneWidget);
    });
  });
}
