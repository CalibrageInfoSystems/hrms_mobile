import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyManager {
  static final _storage = const FlutterSecureStorage();

  /// Generate a unique API key for a user
  static Future<String> generateApiKey(String userId) async {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final rawKey = base64UrlEncode(values);

    // Hash the API key with userId
    final apiKey = sha256.convert(utf8.encode(userId + rawKey)).toString();

    // Store securely
    await _storage.write(key: 'api_key', value: apiKey);

    return apiKey;
  }

  /// Retrieve stored API key
  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }

  /// Delete API key when logging out
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: 'api_key');
  }
}
