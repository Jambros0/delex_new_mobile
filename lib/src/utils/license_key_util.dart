import 'dart:convert';
import 'package:deex_bloc_mobile_app_dev/src/utils/rest_client_util.dart';

class LicenseKeyUtil {
  Future<bool> validateKey(String licenseKey) async {
    final keyToValidate = licenseKey.trim();
    if (keyToValidate.isEmpty) return false;

    bool isSuccess = await _performValidation(keyToValidate);
    if (!isSuccess && !keyToValidate.endsWith('=')) {
      isSuccess = await _performValidation('$keyToValidate=');
    }
    return isSuccess;
  }

  Future<bool> _performValidation(String key) async {
    try {
      final body = {
        'DeviceMngmnt': {"AndroidLicenSeKey": key}
      };
      print('[LICENSE_VALIDATION] Requesting key: "$key"');
      print('[LICENSE_VALIDATION] Request Body: ${jsonEncode(body)}');

      final response = await HttpUtils.getWithBody(
        '/offshore/device-validatekey',
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
        useInterceptor: true,
      );

      print('[LICENSE_VALIDATION] Response Status Code: ${response.statusCode}');
      print('[LICENSE_VALIDATION] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final bool status = data['status'] ?? false;
        print('[LICENSE_VALIDATION] Extracted status: $status');
        return status;
      }
    } catch (e) {
      print('[LICENSE_VALIDATION] Error during validation: $e');
    }
    return false;
  }
}
