import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  // Generate token only once per app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // Get admin bearer token securely
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      // Load credentials from environment variable
      final credentialsPath =
          Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
      if (credentialsPath == null) {
        log('Error: GOOGLE_APPLICATION_CREDENTIALS not set');
        return null;
      }

      final credentialsFile = File(credentialsPath);
      if (!credentialsFile.existsSync()) {
        log('Error: Credentials file not found at $credentialsPath');
        return null;
      }

      final credentialsJson = jsonDecode(credentialsFile.readAsStringSync());

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentialsJson),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;
      return _token;
    } catch (e) {
      log('Error obtaining access token: $e');
      return null;
    }
  }
}
