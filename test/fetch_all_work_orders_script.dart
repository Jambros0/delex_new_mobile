import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('================================================================');
  print('TESTING WORK ORDER API FOR BOTH ONSHORE AND OFFSHORE USERS');
  print('================================================================\n');

  await testUserWorkOrders(
    userType: 'onshore',
    username: 'mobile_onshore',
    password: 'Test@123',
    baseUrl: 'http://94.136.185.87:16000',
  );

  print('\n\n');

  await testUserWorkOrders(
    userType: 'offshore',
    username: 'mobile_offshore',
    password: 'Test@123',
    baseUrl: 'http://94.136.185.87:16000',
  );
}

Future<void> testUserWorkOrders({
  required String userType,
  required String username,
  required String password,
  required String baseUrl,
}) async {
  print('****************************************************************');
  print('SECTION: $userType.toUpperCase()');
  print('Credentials -> Username: $username | Password: $password');
  print('****************************************************************');

  final loginUrl = '$baseUrl/admin/login';
  String token = '';
  String userId = '';
  Map<String, dynamic>? userDetails;

  try {
    final loginResponse = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Login HTTP Status: ${loginResponse.statusCode}');
    if (loginResponse.statusCode == 200) {
      final loginData = jsonDecode(loginResponse.body);
      token = loginData['accessToken'] ?? '';
      userDetails = loginData['user'] ?? loginData['data'] ?? loginData['userDetails'];
      userId = userDetails?['_id'] ?? userDetails?['userId'] ?? userDetails?['id'] ?? '';
      print('Login Successful!');
      print('User ID: $userId');
      print('User Email: ${userDetails?['email']}');
      print('User Role: ${userDetails?['userRole'] ?? userDetails?['role']}');
      print('User Type: ${userDetails?['userType']}');
      print('Bearer Token: ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
    } else {
      print('Login Failed: ${loginResponse.body}');
      return;
    }
  } catch (e) {
    print('Error during login: $e');
    return;
  }

  if (userId.isEmpty || token.isEmpty) {
    print('Cannot fetch work orders: Missing user ID or token');
    return;
  }

  final workOrderUrl = '$baseUrl/$userType/user-work-orders/$userId';
  print('\nRequesting Work Orders from: $workOrderUrl');

  try {
    final response = await http.get(
      Uri.parse(workOrderUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('Work Orders HTTP Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('\nAPI Response Header:');
      print('  status: ${decoded['status']}');
      print('  msg: "${decoded['msg']}"');
      print('  total: ${decoded['total']}');

      final List workOrders = decoded['data'] ?? [];
      print('  Actual Work Orders Count in Data: ${workOrders.length}');

      for (int i = 0; i < workOrders.length; i++) {
        final wo = workOrders[i];
        final String woId = wo['_id'] ?? '';
        final String woNumber = wo['workOrderNumber'] ?? wo['workOrderId'] ?? wo['workorderId'] ?? 'N/A';
        final String title = wo['workOrderTitle'] ?? wo['title'] ?? 'N/A';
        final String desc = wo['description'] ?? 'N/A';
        final String woType = wo['workOrderType'] ?? 'N/A';
        final String status = wo['status'] ?? wo['workOrderStatus'] ?? 'N/A';
        final String woDate = wo['woDate'] ?? wo['createdDate'] ?? wo['createdAt'] ?? 'N/A';
        final List assignedAssets = (wo['assignedAssets'] as List?) ?? [];

        print('\n----------------------------------------------------------------');
        print('WORK ORDER #${i + 1}');
        print('  Mongo ID: $woId');
        print('  WO Number: $woNumber');
        print('  Title: $title');
        print('  Description: $desc');
        print('  Type: $woType');
        print('  Status: $status');
        print('  Date: $woDate');
        print('  Assigned Assets Count: ${assignedAssets.length}');
        print('----------------------------------------------------------------');

        if (assignedAssets.isEmpty) {
          print('  (No assigned assets in this work order)');
          continue;
        }

        print('  ASSIGNED ASSETS LIST:');
        for (int j = 0; j < assignedAssets.length; j++) {
          final a = assignedAssets[j];
          final tag = a['eqpmtTag'] ?? a['equipmentTag'] ?? '(No Tag)';
          final assetDesc = a['description'] ?? '(No Description)';
          final category = a['equipmentCategory'] ?? a['eqpmtCatg'] ?? 'N/A';
          final loc = a['location'] ?? 'N/A';
          final subLoc = a['subLocation'] ?? a['area'] ?? 'N/A';
          final area = a['deckLevel'] ?? a['area'] ?? 'N/A';
          final subArea = a['subArea'] ?? 'N/A';
          final zone = a['zone'] ?? 'N/A';
          final rfid = a['rfidRef'] ?? 'N/A';
          final currentStatus = a['currentStatus'] ?? a['inspectionStatus'] ?? a['status'] ?? 'N/A';
          final assetId = a['_id'] ?? 'N/A';
          final locationId = a['locationId'] ?? 'N/A';
          final workOrderAssetId = a['workOrderAssetId'] ?? 'N/A';

          print('  [$userType Asset ${j + 1}]');
          print('    - Tag: $tag');
          print('    - Description: $assetDesc');
          print('    - Category: $category');
          print('    - Location: $loc | Sub Location: $subLoc | Area: $area | Sub Area: $subArea | Zone: $zone');
          print('    - RFID: $rfid');
          print('    - Status: $currentStatus');
          print('    - Asset ID (_id): $assetId');
          print('    - Location ID: $locationId');
          print('    - Work Order Asset ID: $workOrderAssetId');
        }
      }
    } else {
      print('Failed to fetch work orders. Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error fetching work orders: $e');
  }
}
