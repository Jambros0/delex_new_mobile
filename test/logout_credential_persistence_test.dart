import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Save and retrieve credentials persists across logout session clear', () async {
    final authUtils = AuthUtils();

    // 1. Save credentials and session tokens as if user logged in
    await authUtils.saveCredentials('test_user', 'TestPass123');
    await authUtils.saveSessionTokens('mock_access', 'mock_refresh', 'uid_123');

    // Verify session is active and credentials are saved
    expect(await authUtils.isSessionActive(), true);
    final credsBefore = await authUtils.getSavedCredentials();
    expect(credsBefore['username'], 'test_user');
    expect(credsBefore['password'], 'TestPass123');

    // 2. Clear session tokens (as done during logout)
    await authUtils.clearSessionTokens();

    // Verify session tokens are gone
    expect(await authUtils.isSessionActive(), false);
    final tokens = await authUtils.getSessionTokens();
    expect(tokens['accessToken'], isNull);
    expect(tokens['refreshToken'], isNull);

    // 3. Verify credentials remain intact for prefilling on the login screen
    final credsAfter = await authUtils.getSavedCredentials();
    expect(credsAfter['username'], 'test_user');
    expect(credsAfter['password'], 'TestPass123');
  });
}
