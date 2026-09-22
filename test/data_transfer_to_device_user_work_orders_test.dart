import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/work_order_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDeviceSyncServices extends DeviceSyncServices {
  final Map<String, dynamic> responseToReturn;
  FakeDeviceSyncServices(this.responseToReturn);

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Transfer to Device - user-work-orders Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'userId': '6ab0d7c769bbfa6fbed32d6f',
        'username': 'technician',
        'userType': 'offshore',
      });
    });

    test('WorkOrderTableJson correctly parses assignedAssets array', () {
      final jsonMap = {
        '_id': 'wo_001',
        'woNumber': 'WO-2026-99',
        'woType': 'Preventive',
        'discipline': 'Electrical',
        'assignedTo': '6ab0d7c769bbfa6fbed32d6f',
        'fieldName': 'LNG Terminal',
        'platform': 'Jetty 1',
        'assignedAssets': [
          {
            '_id': 'asset_01',
            'id': 'asset_01',
            'rfidRef': 'RFID-JETTY-01',
            'eqpmtTag': 'MOT-01',
            'description': 'Main Pump Motor',
            'location': 'LNG Terminal',
            'area': 'Jetty 1',
            'deckLevel': 'Level 2',
            'zone': 'Zone 1',
          },
          {
            '_id': 'asset_02',
            'id': 'asset_02',
            'rfidRef': 'RFID-JETTY-02',
            'eqpmtTag': 'VLV-01',
            'description': 'Emergency Shutoff Valve',
            'location': 'LNG Terminal',
            'area': 'Jetty 1',
            'deckLevel': 'Level 2',
            'zone': 'Zone 1',
          }
        ]
      };

      final workOrder = WorkOrderTableJson.fromJson(jsonMap);

      expect(workOrder.id, 'wo_001');
      expect(workOrder.woNumber, 'WO-2026-99');
      expect(workOrder.assets.length, 2);
      expect(workOrder.assets[0].rfidRef, 'RFID-JETTY-01');
      expect(workOrder.assets[0].eqpmtTag, 'MOT-01');
      expect(workOrder.assets[1].rfidRef, 'RFID-JETTY-02');
      expect(workOrder.assets[1].eqpmtTag, 'VLV-01');
    });

    test('DeviceSyncBloc processes user-work-orders response and supports removal after transfer', () async {
      final asset1 = ExRegister.fromJson({
        '_id': 'asset_01',
        'id': 'asset_01',
        'rfidRef': 'RFID-01',
        'eqpmtTag': 'TAG-01',
        'location': 'Field A',
        'area': 'Platform 1',
      });
      final asset2 = ExRegister.fromJson({
        '_id': 'asset_02',
        'id': 'asset_02',
        'rfidRef': 'RFID-02',
        'eqpmtTag': 'TAG-02',
        'location': 'Field A',
        'area': 'Platform 1',
      });

      final workOrder = WorkOrderTableJson(
        id: 'wo_01',
        woNumber: 'WO-01',
        woType: 'Inspection',
        discipline: 'Electrical',
        woDate: DateTime.now(),
        department: 'Ops',
        maintanaceType: 'Routine',
        description: 'Monthly inspection',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        datumDuration: '7d',
        permitType: 'Hot Work',
        priority: 'High',
        attachments: '',
        createdBy: 'admin',
        isActive: true,
        total: '2',
        completed: '0',
        status: 'Open',
        remark: '',
        attachementUrl: '',
        woRequestFormattachements: '',
        woCompletedFormAttachements: '',
        woRequestFormattachementUrl: '',
        woCompletedFormAttachementstUrl: '',
        fieldName: 'Field A',
        platform: 'Platform 1',
        deckLevel: 'Deck 1',
        custodian: '',
        issuedBy: '',
        assigendTeam: '',
        issueDate: '',
        duration: '7d',
        comletionDate: '',
        closedOutBy: '',
        closeOutDate: '',
        progress: '0',
        currentStatus: 'Open',
        remarks: '',
        uploadedDate: DateTime.now(),
        uploadedBy: '',
        workOrderRequest: '',
        riskAssessmentForm: '',
        completeWorkOrderForm: '',
        schedulingStartDate: '',
        schedulingFinishDate: '',
        schedulingDuration: '',
        actualStartDate: '',
        actualFinishDate: '',
        actualDuration: '',
        scheduledVariance: '',
        estimateManPowerCost: '',
        estimatedManHours: '',
        estimateMaterialCost: '',
        estimateMachineryCost: '',
        estimateTotalCost: '',
        actualManHours: '',
        actualManPowerCost: '',
        actualMaterialCost: '',
        actualMachineryCost: '',
        actualTotalCost: '',
        costVariance: '',
        costBudgetRemarks: '',
        projectName: '',
        assets: [asset1, asset2],
        assignedTo: '6ab0d7c769bbfa6fbed32d6f',
      );

      final fakeServices = FakeDeviceSyncServices({
        'tableHeaders': <String>[],
        'assets': [asset1, asset2],
        'work_order': [workOrder],
        'totalRecords': 2,
      });

      final bloc = DeviceSyncBloc(
        deviceSyncServices: fakeServices,
        authUtils: AuthUtils(),
      );

      final states = <DeviceSyncState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadWorkOrder());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.any((s) => s is WorkOrderLoaded), isTrue);
      final loadedState = states.firstWhere((s) => s is WorkOrderLoaded) as WorkOrderLoaded;
      expect(loadedState.assets.length, 2);

      // Now simulate user transferring asset_01 to local DB:
      bloc.add(RemoveTransferredAssetsFromDeviceSync(['asset_01']));
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedState = bloc.state as WorkOrderLoaded;
      expect(updatedState.assets.length, 1);
      expect(updatedState.assets.first.id, 'asset_02');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('asset_ids'), ['asset_02']);
    });
  });
}
