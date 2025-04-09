import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiKey {
  String name;
  DateTime createdAt;
  bool isActive;
  String issuedBy;
  int id;

  ApiKey({
    required this.name,
    required this.createdAt,
    required this.isActive,
    required this.issuedBy,
    required this.id,
  });
}

class EncryptionHelper {
  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 chars
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptText(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }

  static String decryptText(String text) {
    return encrypter.decrypt64(text, iv: iv);
  }

  static const String partitionKey = '|';
}

class ApiKeyManager {
  final List<ApiKey> _apiKeys = [];

  Future<String> generateApiKey(String keyFor, String token) async {
    try {
      final decoded = JwtDecoder.decode(token);
      final userId = decoded['Id']?.toString() ?? 'unknown_user';

      final key = _encryptApiKey('$keyFor${EncryptionHelper.partitionKey}$userId');

      final apiKey = ApiKey(
        name: keyFor,
        createdAt: DateTime.now().toUtc(),
        isActive: true,
        issuedBy: userId,
        id: _apiKeys.length + 1,
      );

      _apiKeys.add(apiKey);

      final userKey = _encryptApiKey(apiKey.id.toString());
      return '$key${EncryptionHelper.partitionKey}$userKey';
    } catch (e) {
      throw Exception('Failed to generate API key: $e');
    }
  }

  String _encryptApiKey(String keyFor) {
    return EncryptionHelper.encryptText(keyFor);
  }

  String _decryptApiKey(String encrypted) {
    return EncryptionHelper.decryptText(encrypted);
  }
}
