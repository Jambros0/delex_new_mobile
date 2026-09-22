import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_event.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_state.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/ui/screens/device_sync.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/services/ex_register_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';

class MockToServerBloc extends ToServerBloc {
  final List<ExRegister> mockAssets;
  final List<String> mockHeaders;

  MockToServerBloc({required this.mockAssets, required this.mockHeaders})
      : super(
          exRegisterService: ExRegisterService(),
          authUtils: AuthUtils(),
        );

  @override
  FutureOr<void> loadWorkOrderToServer(
      WorkOrderToServerLoad event, Emitter<ToServerState> emit) {
    emit(WorkOrderToServerLoaded(
      tableHeaders: mockHeaders,
      assets: mockAssets,
      totalRecords: mockAssets.length,
      isLoadMore: false,
      filterIndex: null,
      skip: mockAssets.length,
      sortOrder: 'descending',
    ));
  }
}

class MockDeviceSyncBloc extends DeviceSyncBloc {
  MockDeviceSyncBloc()
      : super(
          deviceSyncServices: DeviceSyncServices(),
          authUtils: AuthUtils(),
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncPopupScreen - Data Transfer To Server Tests', () {
    testWidgets('renders table and 6 records in modal without blank screen or exceptions', (WidgetTester tester) async {
      final List<ExRegister> sixAssets = List.generate(6, (index) {
        return ExRegister.fromJson({
          '_id': 'asset_$index',
          'id': 'asset_$index',
          'rfidRef': 'RFID-00${index + 1}',
          'location': 'Location ${index + 1}',
          'area': 'Area ${index + 1}',
          'deckLevel': 'Level ${index + 1}',
          'zone': 'Zone 1',
          'eqpmtCatg': 'Electrical',
          'eqpmtTag': 'TAG-00${index + 1}',
          'description': 'Description ${index + 1}',
          'manufacturer': 'Manufacturer ${index + 1}',
          'protectionType': ['Ex d'],
          'equipmentGasGroup': ['IIB'],
          'equipmentTClass': ['T4'],
          'faultyItems': index % 2 == 0 ? null : 'Defect code 1',
          'inspectionStatus': index == 0 ? 'Green' : (index == 1 ? 'Red' : ''),
          'repairsDone': index == 2 ? 'Replaced seal' : null,
          'existingFaults': null,
          'currentStatus': 'Active',
        });
      });

      final headers = [
        "RFID Reference",
        "Field Name",
        "Platform",
        "Deck Level",
        "Zone",
        "Discipline",
        "Equipment Tag Number",
        "Equipment Description",
        "Manufacturer",
        "Equipment Protection",
        "Inspection Faults",
        "Inspection Status",
        "Completed Repairs",
        "Existing Faults",
        "Current Status"
      ];

      final mockToServerBloc = MockToServerBloc(mockAssets: sixAssets, mockHeaders: headers);
      final mockDeviceSyncBloc = MockDeviceSyncBloc();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ToServerBloc>.value(value: mockToServerBloc),
            BlocProvider<DeviceSyncBloc>.value(value: mockDeviceSyncBloc),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Dialog(
                backgroundColor: Colors.transparent,
                child: SyncPopupScreen(
                  title: 'Data Transfer To Server',
                  buttonText: 'Transfer To Server',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and footer
      expect(find.text('Data Transfer To Server'), findsOneWidget);
      expect(find.text('Total Records: 6'), findsOneWidget);
      expect(find.text('Transfer To Server'), findsOneWidget);

      // Verify table headers are visible
      expect(find.text('RFID Reference'), findsOneWidget);
      expect(find.text('Equipment Tag Number'), findsOneWidget);

      // Verify asset rows are rendered
      expect(find.text('RFID-001'), findsOneWidget);
      expect(find.text('TAG-001'), findsOneWidget);
      expect(find.text('RFID-006'), findsOneWidget);
      expect(find.text('TAG-006'), findsOneWidget);
    });
  });
}
